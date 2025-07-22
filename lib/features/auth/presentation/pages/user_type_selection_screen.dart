import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import 'signup_screen.dart';
import '../../../customer/presentation/pages/customer_home_screen.dart';
import '../../../driver/presentation/pages/driver_home_screen.dart';
import '../../../agent/presentation/pages/agent_main_shell.dart';
import '../../../agent/presentation/pages/agent_home_screen.dart';
import '../../../supervisor/presentation/pages/supervisor_home_screen.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.slateGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppTheme.slate900,
                      size: 28,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Choose Your Role',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.slate900,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Select your role to get started with Areno Express',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.slate600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // User Type Cards
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildUserTypeCard(
                        context,
                        'Customer',
                        'Get quotes and track shipments',
                        Icons.person,
                        AppTheme.primaryBlue,
                        'customer',
                      ),
                      _buildUserTypeCard(
                        context,
                        'Motorbike Driver',
                        'Handle local deliveries',
                        Icons.motorcycle,
                        AppTheme.primaryOrange,
                        'driver',
                      ),
                      _buildUserTypeCard(
                        context,
                        'Agent',
                        'Manage pickup and dropoff points',
                        Icons.store,
                        AppTheme.successGreen,
                        'agent',
                      ),
                      _buildUserTypeCard(
                        context,
                        'Supervisor',
                        'Manage freight and moving operations',
                        Icons.manage_accounts,
                        AppTheme.slate700,
                        'supervisor',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    String userType,
  ) {
    return GestureDetector(
      onTap: () {
        Widget target;
        switch (userType) {
          case 'customer':
            target = const CustomerHomeScreen();
            break;
          case 'driver':
            target = const DriverHomeScreen();
            break;
          case 'agent':
            target = const AgentMainShell();
            break;
          case 'supervisor':
            target = const SupervisorHomeScreen();
            break;
          default:
            target = const CustomerHomeScreen();
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => target),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.slate900.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.slate900,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
