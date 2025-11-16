// lib/app/modules/profile/views/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/auth_models.dart'; // Import your auth models
import '../../../widget/custom_widgets/ticket_actions_widget.dart';


class ProfileScreen extends StatelessWidget {
  final AuthService authService = Get.find<AuthService>();

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        authService.signOut();
                        Get.offAllNamed('/login');
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        final UserData? user = authService.userData.value;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // User Profile Card
              _buildProfileCard(user),
              const SizedBox(height: 20),

              // My Tickets Section
              _buildTicketsSection(),
              const SizedBox(height: 20),

              // Settings Section
              _buildSettingsSection(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileCard(UserData? user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[100],
              ),
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.blue[600],
              ),
            ),
            const SizedBox(height: 16),

            // User Name - Using your actual UserData fields
            Text(
              '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim().isEmpty 
                  ? 'User Name' 
                  : '${user?.firstName} ${user?.lastName}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // User Email - Using your actual UserData field
            Text(
              user?.email ?? 'user@example.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            
            // User Phone - Using your actual UserData field
            if (user?.phone != null && user!.phone.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                user.phone,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
            
            const SizedBox(height: 16),

            // Edit Profile Button
            OutlinedButton(
              onPressed: () {
                Get.snackbar(
                  'Coming Soon',
                  'Edit profile feature will be available soon',
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                );
              },
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  // ... rest of your ProfileScreen methods remain the same
  Widget _buildTicketsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Tickets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your bus tickets and bookings',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Sample Ticket - In a real app, you'd loop through user's bookings
            _buildSampleTicketItem(),
            const SizedBox(height: 12),
            _buildSampleTicketItem2(),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleTicketItem() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'NYC → Boston',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Text(
                  'Confirmed',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Date and Time
          Text(
            'Nov 16, 2024 • 08:00 AM',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),

          // Ticket Actions
          TicketActionsWidget(
            bookingId: '6919d177f0fbb055f405ccc2',
            pnrNumber: 'PNR1763299703393axq1m',
          ),
        ],
      ),
    );
  }

  Widget _buildSampleTicketItem2() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Harare → Bulawayo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Text(
                  'Pending',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Nov 20, 2024 • 10:00 AM',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          TicketActionsWidget(
            bookingId: '6919ccd9f0fbb055f405cca4',
            pnrNumber: 'PNR1763298521309jhaxy',
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingsOption(
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () {
                Get.snackbar(
                  'Notifications',
                  'Notification settings will be available soon',
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                );
              },
            ),
            _buildSettingsOption(
              icon: Icons.security,
              title: 'Privacy & Security',
              onTap: () {
                Get.snackbar(
                  'Privacy',
                  'Privacy settings will be available soon',
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                );
              },
            ),
            _buildSettingsOption(
              icon: Icons.help,
              title: 'Help & Support',
              onTap: () {
                Get.snackbar(
                  'Help',
                  'Help center will be available soon',
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                );
              },
            ),
            _buildSettingsOption(
              icon: Icons.info,
              title: 'About',
              onTap: () {
                Get.snackbar(
                  'About',
                  'About information will be available soon',
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}