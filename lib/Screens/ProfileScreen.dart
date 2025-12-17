import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'EditProfileScreen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final String userName = 'David Robinson';
  final String userEmail = 'email@example.com';

  bool notificationsEnabled = true;
  bool darkModeEnabled = false;

  void _logout(BuildContext context) async {
    try {
      await ref.read(authServiceProvider).logout();
      ref.read(authStateProvider.notifier).state = const AsyncValue.data(null);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la déconnexion: $e')),
        );
      }
    }
  }


  void _launchHelpUrl() async {
    final Uri url = Uri.parse('https://avempace-wireless.com/index.php/contacts/');
    try {
      await launchUrl(url, mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint("Error opening URL : $e");
    }
  }

  Widget _buildSwitchItem(String title, bool value, Function(bool) onChanged, String assetPath) {
    return ListTile(
      leading: const Icon(Icons.notifications_none, size: 33, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontSize: 18)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, String iconName, String title, {VoidCallback? onTap}) {
    // Mappage des noms d'icônes aux icônes Flutter
    final iconMap = {
      'person': Icons.person_outline,
      'password': Icons.lock_outline,
      'notifications': Icons.notifications_outlined,
      'dark_mode': Icons.dark_mode_outlined,
      'help': Icons.help_outline,
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                iconMap[iconName] ?? Icons.error_outline,
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool isOldVisible = false;
    bool isNewVisible = false;
    bool isConfirmVisible = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Change Password',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // OLD PASSWORD
                      TextFormField(
                        controller: oldPasswordController,
                        obscureText: !isOldVisible,
                        decoration: InputDecoration(
                          labelText: 'Old Password',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(Icons.lock_outline, color: Colors.grey),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isOldVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () => setModalState(() => isOldVisible = !isOldVisible),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your old password";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // NEW PASSWORD
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: !isNewVisible,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(Icons.lock_outline, color: Colors.grey),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isNewVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () => setModalState(() => isNewVisible = !isNewVisible),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a new password";
                          }
                          if (value.length < 8) {
                            return "Password must be at least 8 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // CONFIRM PASSWORD
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: !isConfirmVisible,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(Icons.lock_outline, color: Colors.grey),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isConfirmVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () => setModalState(() => isConfirmVisible = !isConfirmVisible),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value != newPasswordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text("Modify", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.person, size: 50, color: Colors.blue),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(userEmail, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text("Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _buildSettingItem(
                context,
                'person', // Icône utilisateur
                "Manage user",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const EditProfileScreen()),
                ),
              ),
              _buildSettingItem(
                context,
                'password', // Icône mot de passe
                "Change Password",
                onTap: () => _showChangePasswordSheet(context),
              ),


              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _logout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      foregroundColor: Colors.blue,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout, size: 24),
                    label: const Text(
                      "Sign Out",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
