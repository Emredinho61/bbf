import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class IconButtonForPayPal extends StatelessWidget {
  const IconButtonForPayPal({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final Uri url = Uri.parse(
          'https://www.paypal.com/donate/?hosted_button_id=ESTNXJLMMQQQS#',
        );
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          debugPrint('Konnte $url nicht öffnen');
        }
      },
      child: Align(
        alignment: Alignment.center,
        child: Container(
          height: 60.h,
          width: 60.w,
          decoration: BoxDecoration(
            color: isDark ? Colors.green.shade300 : Colors.green.shade200,
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Image.asset('assets/images/PayPalLogo.png'),
        ),
      ),
    );
  }
}

class BankInfoCard extends StatelessWidget {
  const BankInfoCard({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Copyable text
    Widget copyableRow(String label, String value) {
      return Row(
        children: [
          Expanded(
            child: Text(
              "$label: $value",
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          IconButton(
            icon: Icon(Icons.copy, size: 18.sp),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("$label copied!")));
            },
          ),
        ],
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        border: Border.all(color: isDark ? Colors.white : Colors.green),
      ),
      child: ListTile(
        leading: const Icon(Icons.account_balance),
        title: Center(
          child: Text(
            "Bildungs- und Begegnungsverein Freiburg e.V.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            copyableRow("IBAN", "DE11 6805 0101 0014 3501 24"),
            copyableRow("BIC", "FRSPDE66XXX"),
            copyableRow("Verwendungszweck", "Spende"),
          ],
        ),
      ),
    );
  }
}

class DividerWithText extends StatelessWidget {
  const DividerWithText({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50.w,
            child: Divider(
              color: isDark ? Colors.white : Colors.black,
              thickness: 1,
            ),
          ),
          SizedBox(width: 10.w),
          Text('oder'),
          SizedBox(width: 10.w),
          SizedBox(
            width: 50.w,
            child: Divider(
              color: isDark ? Colors.white : Colors.black,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
