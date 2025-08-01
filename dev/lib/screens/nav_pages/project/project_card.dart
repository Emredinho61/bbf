import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class Project extends StatelessWidget {
  final String title;
  final String content;
  const Project({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(8.0),
      child: Card(
        child: Padding(
          padding: EdgeInsetsGeometry.all(8.0), 
          child: Column(
            children: [
              SizedBox(height: 10),
              Text(title, style: Theme.of(context).textTheme.headlineSmall,),
              SizedBox(height: 10),
              Image.asset(
                'assets/images/bbf-logo.png', 
                height: 100,
                width: 50
              ),
              SizedBox(height: 15),

              Expanded(
                child: Text(content,
                maxLines: 7,
                overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height:5),
              
              // Centering the button 
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      showMoreBottomSheet(context);
                    },
                    child: Text('Mehr anzeigen', style: Theme.of(context).textTheme.labelLarge,), 
                    ),
                ),
              )

            ]
            
          ),
          ),
      )
      );
  }

  Future<dynamic> showMoreBottomSheet(BuildContext context) {
    return showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor:  Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 :  BColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25)
                        )
                      ),
                      builder: (context) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.9,
                          width: double.infinity,
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                              child: Column(
                                children: [
                                  Text(title, style: Theme.of(context).textTheme.headlineLarge),
                                  SizedBox(height: 10),
                                  Image.asset('assets/images/bbf-logo.png', height: 100, width: 50,),
                                  SizedBox(height: 10),
                                  Text(content)
                                ],
                              ),
                            ),
                          ),
                        );
                      },

                    );
  }
}