import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../config/app_colors.dart';
import '../cubit/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.background),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.of(context).pushReplacementNamed('/garage');
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Text('Tukir.ID', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(AppColors.textPrimary))),
                SizedBox(height: 8),
                Text('Smart Garage Assistant', style: TextStyle(fontSize: 14, color: Color(AppColors.textSecondary))),
                SizedBox(height: 48),
                TextField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Color(AppColors.textSecondary)),
                    filled: true,
                    fillColor: Color(AppColors.surface),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  style: TextStyle(color: Color(AppColors.textPrimary)),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Color(AppColors.textSecondary)),
                    filled: true,
                    fillColor: Color(AppColors.surface),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  style: TextStyle(color: Color(AppColors.textPrimary)),
                ),
                SizedBox(height: 24),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final loading = state is AuthLoading;
                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: loading ? null : () => context.read<AuthCubit>().login(_emailCtrl.text, _passwordCtrl.text),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(AppColors.active),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: loading ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text('Login', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        if (state is AuthError) ...[
                          SizedBox(height: 16),
                          Text(state.message, style: TextStyle(color: Color(AppColors.danger), fontSize: 12)),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }
}
