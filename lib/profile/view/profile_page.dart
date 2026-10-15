import 'dart:async';

import 'package:evently_vendor/app/bloc/app_bloc.dart';
import 'package:evently_vendor/app/routing/app_routes.dart';
import 'package:evently_vendor/profile/cubit/profile_cubit.dart';
import 'package:evently_vendor/profile/cubit/profile_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Profile tab. The [ProfileCubit] is provided by the app shell so Home and
/// Profile share one loaded profile.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listenWhen: (previous, current) =>
          !previous.signOutFailed && current.signOutFailed,
      listener: (context, state) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't log out. Please try again."),
          backgroundColor: Color(0xFFEF4444),
        ),
      ),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  String _getInitials(String name) {
    final names = name.trim().split(' ');
    if (names.isEmpty || names.first.isEmpty) return '??';
    if (names.length == 1) return names.first[0].toUpperCase();
    return '${names.first[0]}${names.last[0]}'.toUpperCase();
  }

  void _onLogout(BuildContext context) {
    // Show confirmation dialog before logging out
    unawaited(
      showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(ctx).pop();
                context.read<AppBloc>().add(const AppSignOutRequested());
              },
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                  fontFamily: 'Inter',
                ),
              ),
            ),

            // Body
            Expanded(
              child: BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  if (state.status == ProfileStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF4040),
                      ),
                    );
                  }

                  if (state.status == ProfileStatus.failure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Failed to load profile.'),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () =>
                                context.read<ProfileCubit>().fetchProfile(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final profile = state.profile;
                  if (profile == null) return const SizedBox.shrink();

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 72),
                    child: Column(
                      children: [
                        // Profile Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 28, 16, 20),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAFAFA),
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _getInitials(profile.businessName),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                profile.businessName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    profile.category,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF6B7280),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      '·',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF6B7280),
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                  Text(
                                    profile.location,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF6B7280),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 36,
                                child: OutlinedButton.icon(
                                  onPressed: () => unawaited(
                                    context.push(AppRoutes.editBusiness),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFFF4040),
                                    side: const BorderSide(
                                      color: Color(0xFFFF4040),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 14,
                                  ),
                                  label: const Text(
                                    'Edit Business',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Sections
                        _buildSection(
                          title: 'BUSINESS',
                          items: [
                            _buildRowItem(
                              'Business Name',
                              profile.businessName,
                            ),
                            _buildRowItem('Category', profile.category),
                            _buildRowItem('Location', profile.location),
                          ],
                        ),

                        _buildSection(
                          title: 'ACCOUNT',
                          items: [
                            _buildRowItem('Phone Number', profile.phone),
                            _buildRowItem('Email', profile.email),
                          ],
                        ),

                        _buildSection(
                          title: 'MANAGE',
                          items: [
                            InkWell(
                              onTap: () => unawaited(
                                context.push(AppRoutes.services),
                              ),
                              child: _buildRowItemWidget(
                                'Services',
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 20,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Log Out
                        Container(
                          margin: const EdgeInsets.only(top: 24),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Color(0xFFE5E7EB)),
                              bottom: BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                          ),
                          child: InkWell(
                            onTap: () => _onLogout(context),
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                'Log Out',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFFF4040),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                        ),

                        // App Version
                        const Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 8),
                          child: Text(
                            'Evently v1.0.0',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF9CA3AF),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> items}) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9CA3AF),
                letterSpacing: 0.66, // 0.06em * 11
                fontFamily: 'Inter',
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Column(
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowItem(String title, String value) {
    return _buildRowItemWidget(
      title,
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.end,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Color(0xFF6B7280),
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildRowItemWidget(String title, Widget trailing) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF111827),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(width: 16),
          // Long values (e.g. business names) truncate instead of
          // overflowing the row.
          Expanded(
            child: Align(alignment: Alignment.centerRight, child: trailing),
          ),
        ],
      ),
    );
  }
}
