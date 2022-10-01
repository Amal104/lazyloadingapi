import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController controller = ScrollController();

  List<String> items = [];
  int page = 1;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    fetch();
    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.offset) {
        fetch();
      }
    });
  }

  Future fetch() async {
    const limit = 25;
    final url = Uri.parse(
        'https://jsonplaceholder.typicode.com/posts?_limit=$limit&_page=$page');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List newItems = json.decode(response.body);
      setState(() {
        page++;
        if (newItems.length < limit) {
          hasMore = false;
        }
        items.addAll(newItems.map<String>((item) {
          final title = item['title'];
          return '$title';
        }).toList());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lazy Loading'),
      ),
      body: ListView.builder(
        controller: controller,
        padding:const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index < items.length) {
            final item = items[index];
            return ListTile(
              title: Text(
                item,
                style:const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: hasMore
                    ? LottieBuilder.asset('assets/loading.json',height: 150.0,width: 150)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.warning,
                            color: Colors.teal,
                            size: 18,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'No more data to load',
                            style: TextStyle(
                                color: Color(0xFF009688),
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            );
          }
        },
      ),
    );
  }
}
