// ignore_for_file: deprecated_member_use

import 'package:bbf_app/backend/services/feedback_service.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? BColors.backgroundColorDark
          : const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: isDark ? BColors.prayerRowDark : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1C1E),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18.sp,
            color: BColors.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mitmachen & Feedback',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          // Intro
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [BColors.primary, BColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.handshake_outlined,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Deine Meinung zählt! Hilf uns, den Verein und die App zu verbessern.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          _FeedbackCard(
            icon: Icons.volunteer_activism_outlined,
            title: 'Wie kann ich dem Verein helfen?',
            description:
                'Teile uns mit, womit du den Verein unterstützen möchtest. Wir melden uns per E-Mail bei dir.',
            hint: '',
            type: 'help',
            requiresEmail: true,
            isDark: isDark,
          ),

          SizedBox(height: 14.h),

          _FeedbackCard(
            icon: Icons.star_outline_rounded,
            title: 'Was wünsche ich mir vom Verein?',
            description:
                'Welche Angebote oder Aktivitäten wünschst du dir vom BBF-Verein?',
            hint: '',
            type: 'wish',
            requiresEmail: false,
            isDark: isDark,
          ),

          SizedBox(height: 14.h),

          _FeedbackCard(
            icon: Icons.phone_android_outlined,
            title: 'Was vermisse ich in der App?',
            description:
                'Welche Funktion oder welcher Inhalt fehlt dir in der BBF-App?',
            hint: '',
            type: 'app',
            requiresEmail: false,
            isDark: isDark,
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

// ── Feedback card ─────────────────────────────────────────────────────────────

class _FeedbackCard extends StatefulWidget {
  const _FeedbackCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.hint,
    required this.type,
    required this.requiresEmail,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String description;
  final String hint;
  final String type;
  final bool requiresEmail;
  final bool isDark;

  @override
  State<_FeedbackCard> createState() => _FeedbackCardState();
}

class _FeedbackCardState extends State<_FeedbackCard> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FeedbackService _feedbackService = FeedbackService();
  bool _isSubmitting = false;
  bool _submitted = false;
  String? _error;

  @override
  void dispose() {
    _textController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _textController.text.trim();
    final email = _emailController.text.trim();

    if (text.isEmpty) {
      setState(() => _error = 'Bitte etwas eingeben.');
      return;
    }
    if (widget.requiresEmail && email.isEmpty) {
      setState(() => _error = 'Bitte eine E-Mail-Adresse angeben.');
      return;
    }
    if (widget.requiresEmail && !email.contains('@')) {
      setState(() => _error = 'Bitte eine gültige E-Mail-Adresse eingeben.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await _feedbackService.submitFeedback(
        type: widget.type,
        text: text,
        email: widget.requiresEmail ? email : null,
      );

      if (mounted) setState(() => _submitted = true);
    } catch (e) {
      if (mounted)
        setState(() => _error = 'Fehler beim Senden. Versuche es erneut.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? BColors.prayerRowDark : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _submitted ? _successView(isDark) : _formView(isDark),
    );
  }

  Widget _successView(bool isDark) {
    return Column(
      children: [
        Container(
          width: 52.r,
          height: 52.r,
          decoration: BoxDecoration(
            color: BColors.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            color: BColors.primary,
            size: 28.sp,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Vielen Dank!',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Dein Beitrag wurde erfolgreich übermittelt.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
        ),
        SizedBox(height: 14.h),
        TextButton.icon(
          onPressed: () => setState(() {
            _submitted = false;
            _textController.clear();
            _emailController.clear();
            _error = null;
          }),
          icon: Icon(Icons.add, size: 16.sp, color: BColors.primary),
          label: Text(
            'Weiteren Beitrag senden',
            style: TextStyle(
              fontSize: 13.sp,
              color: BColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _formView(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: BColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, color: BColors.primary, size: 18.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 8.h),

        Text(
          widget.description,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade500,
            height: 1.4,
          ),
        ),

        SizedBox(height: 14.h),

        // Text input
        _inputField(
          controller: _textController,
          label: 'Deine Antwort',
          hint: widget.hint,
          isDark: isDark,
          maxLines: 4,
        ),

        if (widget.requiresEmail) ...[
          SizedBox(height: 10.h),
          _inputField(
            controller: _emailController,
            label: 'Deine E-Mail-Adresse',
            hint: 'name@beispiel.de',
            isDark: isDark,
            keyboardType: TextInputType.emailAddress,
          ),
        ],

        if (_error != null) ...[
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade400,
                size: 14.sp,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  _error!,
                  style: TextStyle(fontSize: 12.sp, color: Colors.red.shade400),
                ),
              ),
            ],
          ),
        ],

        SizedBox(height: 14.h),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: BColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 13.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: _isSubmitting
                ? SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Absenden',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      cursorColor: BColors.primary,
      onChanged: (_) {
        if (_error != null) setState(() => _error = null);
      },
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
        fontSize: 14.sp,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13.sp),
        filled: true,
        fillColor: isDark
            ? BColors.backgroundColorDark
            : const Color(0xFFF7F7F7),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.25),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.25),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: BColors.primary.withOpacity(0.6),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
