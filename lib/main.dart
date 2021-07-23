import 'dart:math';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hmm/hmm/hmm.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HMM',
      supportedLocales: const [
        Locale("en", "US"),
        Locale("fa", "IR"),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale("fa", "IR"),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: "vazir",
      ),
      home: const MyHomePage(title: 'محاسبه مدل مخفی مارکف'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class SelectedWord {
  final String name;
  final String id;
  const SelectedWord({
    required this.name,
    required this.id,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SelectedWord && other.name == name && other.id == id;
  }

  @override
  int get hashCode => name.hashCode ^ id.hashCode;
}

class _MyHomePageState extends State<MyHomePage> {
  List<SelectedWord> selectedWord = [];
  final boxDecoration = BoxDecoration(
    border: Border.all(
      width: 2,
      color: Colors.grey.withOpacity(0.5),
    ),
    borderRadius: BorderRadius.circular(16),
  );
  @override
  Widget build(BuildContext context) {
    final wordList = selectedWord.map((e) => e.name);
    final data = hmmCalc(wordList.toList());
    final bool canAddMore = !(data.isEmpty && selectedWord.isNotEmpty);
    double maxProb = 0;
    if (data.isNotEmpty) {
      maxProb =
          data.length > 1 ? data.map((e) => e.prob).reduce(max) : data[0].prob;
    }
    final color = canAddMore ? Colors.green : Colors.red;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        elevation: 2,
      ),
      body: Center(
        child: SizedBox(
          width: 650,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: boxDecoration,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 16,
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child:
                            Text("برای افزودن هر کلمه بر روی حروف کلیک کنید"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          runAlignment: WrapAlignment.center,
                          spacing: 8,
                          children: HMM.kWORDS
                              .map(
                                (e) => Container(
                                  margin: const EdgeInsets.all(4),
                                  child: OutlinedButton(
                                    key: ValueKey(e.toString() + "button"),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: color, width: 2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        e,
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 28,
                                        ),
                                      ),
                                    ),
                                    onPressed: !canAddMore
                                        ? null
                                        : () {
                                            setState(() {
                                              selectedWord.add(SelectedWord(
                                                  name: e,
                                                  id: DateTime.now()
                                                      .toIso8601String()));
                                            });
                                          },
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: boxDecoration,
                  child: Column(
                    children: [
                      Text(
                        "برای حذف بر روی کلمات کلیک کنید",
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(
                              color: Colors.red,
                            ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Builder(builder: (context) {
                          return Wrap(
                            children: selectedWord
                                .map(
                                  (e) => Container(
                                    margin: const EdgeInsets.all(4),
                                    child: OutlinedButton(
                                      key: ValueKey(e.toString() + "sel"),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          e.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6,
                                        ),
                                      ),
                                      onPressed: () {
                                        selectedWord.removeWhere(
                                            (element) => element == e);
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 24,
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.only(
                  top: 0,
                  right: 24,
                  left: 24,
                  bottom: 8,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    "احتمال های محاسبه شده (احتمال هایی که با رنگ سبر مشخص شدند محتمل ترین احتمال ها هستند)",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  data
                      .map(
                        (e) => Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              width: 3,
                              color: (e.prob == maxProb
                                      ? Colors.green
                                      : Colors.red)
                                  .withAlpha(160),
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              // display(e.prob),
                              " احتمال : ${e.prob.toString()} ",
                            ),
                            subtitle: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Builder(builder: (context) {
                                return Wrap(
                                  runSpacing: 8,
                                  spacing: 12,
                                  children: e.states
                                      .map((e) => Column(children: [
                                            Text(
                                              "--> $e ",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline6,
                                            )
                                          ]))
                                      .toList(),
                                );
                              }),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              if (selectedWord.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: boxDecoration,
                    child: Center(
                      child: Text(
                        "لطفا از کلمات بالا انتخاب کنید",
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                  ),
                ),
              if (selectedWord.isNotEmpty && data.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: boxDecoration,
                    child: Center(
                      child: Text(
                        "احتمال این ترکیب در این مدل وجود ندارد",
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 72,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          right: 28.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("نمایش نمودار و جدول مدل"),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    content: Image.asset(
                      "assets/hmm.jpg",
                      width: 400,
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextButton(
                          child: const Text("بستن"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      )
                    ],
                  ),
                );
              },
              label: const Text("تصاویر مدل"),
              icon: const Icon(Icons.image),
            ),
          ],
        ),
      ),
    );
  }
}
