# محاسبه مدل مخفی مارکف

[برای مشاهده و کار کردن با ظاهر برو روی لینک کلیک کنید](https://setbap.github.io/hmm/)

## نحوه کار

ویدیو زیر نحوه کار با سایت را نشان می دهد

<p align='center'>
    <img  src="https://raw.githubusercontent.com/setbap/hmm/main/hmm.gif" />
</p>

## معرفی بخش ها

این پروژه از دو بخش تشکبل شده است

1.  فایل `main.dart`
2.  فایل `hmm.dart`

## main.dart

این فایل مسئول بخش ظاهر این پروژه میباشد

## hmm.dart

این فایل مسئول بخش محاسباتی پروژه می باشد. مدل و تابع `hmmCalc` با دریافت ارایه ای کلمات موجود در لیست کلمات قبول درصد احتمال هر حالت محاسبه میکند.

## نحوه محاسبه hmm

برای محاسبه ابتدا باید مدل آن مشخص شود. شکل زیر مدل و احتمال آن را نشان می دهد

<p align='center'>
    <img width="400px" src="https://raw.githubusercontent.com/setbap/hmm/main/assets/hmm.jpg" />
</p>

### کلاس HMM

این کلاس مسثولیت نگهداری اطلاعات مدل را دارد.خطوط زیر برای تعریف کلمات و حالات و وزن این مدل تعریف شدند

```dart
  static const List<String> kWORDS = [
    "boat",
    "man",
    "old",
    "rows",
    "the",
    ".",
  ];
  final Map<String, List<double>> outputProb = {
    kWORDS[0]: [0.2, 0.0, 0.2, 0.0],
    kWORDS[1]: [0.2, 0.2, 0.2, 0.0],
    kWORDS[2]: [0.2, 0.0, 0.2, 0.0],
    kWORDS[3]: [0.1, 0.8, 0.1, 0.0],
    kWORDS[4]: [0.3, 0.0, 0.3, 0.0],
    kWORDS[5]: [0.0, 0.0, 0.0, 1.0],
  };
  static const stateNumber = {
    "subject": 0,
    "verb": 1,
    "object": 2,
    "end": 3,
  };
  static const stateName = [
    "subject",
    "verb",
    "object",
    "end",
  ];
  final Map<String, List<Map<String, Object>>> stateOutProb = {
    stateName[0]: [
      {"name": stateName[0], "prob": 0.5},
      {"name": stateName[1], "prob": 0.5},
    ],
    stateName[1]: [
      {"name": stateName[2], "prob": 0.7},
      {"name": stateName[3], "prob": 0.3},
    ],
    stateName[2]: [
      {"name": stateName[2], "prob": 0.5},
      {"name": stateName[3], "prob": 0.5},
    ],
    stateName[3]: [
      {"name": stateName[3], "prob": 1.0},
    ],
  };
  final Map<String, Map<String, double>> stateWordProb = {
    stateName[0]: {
      kWORDS[0]: 0.2,
      kWORDS[1]: 0.2,
      kWORDS[2]: 0.2,
      kWORDS[3]: 0.1,
      kWORDS[4]: 0.3,
      kWORDS[5]: 0.0,
    },
    stateName[1]: {
      kWORDS[0]: 0.0,
      kWORDS[1]: 0.2,
      kWORDS[2]: 0.0,
      kWORDS[3]: 0.8,
      kWORDS[4]: 0.0,
      kWORDS[5]: 0.0,
    },
    stateName[2]: {
      kWORDS[0]: 0.2,
      kWORDS[1]: 0.2,
      kWORDS[2]: 0.2,
      kWORDS[3]: 0.1,
      kWORDS[4]: 0.3,
      kWORDS[5]: 0.0,
    },
    stateName[3]: {
      kWORDS[0]: 0.0,
      kWORDS[1]: 0.0,
      kWORDS[2]: 0.0,
      kWORDS[3]: 0.0,
      kWORDS[4]: 0.0,
      kWORDS[5]: 1.0,
    },
  };

```

#### تابع زیر احتمال یک کلمه در یک حالت را محاسبه می کند و بر می گرداند

```dart
  double getProbWordInState({
    required String word,
    required String state,
  }) {
    final getStateNumber = stateNumber[state]!;
    return outputProb[word]![getStateNumber];
  }
```

#### تابع زیر با دریافت یک کلمه و حالت قبلی , حالت قابل دسترس و احتمال آن را محاسبه می کند

```dart
  List<Map<String, Object>> findPossibleNextState({
    required String prevState,
    required String word,
  }) {
    final nextStateProp = stateOutProb[prevState]!;
    final List<Map<String, Object>> data = [];
    for (var element in nextStateProp) {
      final nameOfState = element["name"];
      final probOfState = element["prob"] as double;
      final indexOfState = stateWordProb[nameOfState]!;
      final wordInStateProb = indexOfState[word]!;
      if (wordInStateProb * probOfState != 0) {
        data.add({
          "state": element["name"] as String,
          "prob": wordInStateProb * probOfState,
        });
      }
    }
    return data;
  }
```

#### کلاس زیر وظیفه نگداری مسیر پیموده شده و احتمال پیمایش این مسیر را دارد

```dart

class Path {
  final List<String> states;
  final double prob;

  Path({
    required this.states,
    required this.prob,
  });
  get currentState => states.last;

  Path copyWith({
    required String newState,
    required double newProb,
  }) {
    return Path(
      states: [...states, newState],
      prob: prob * newProb,
    );
  }
}

```

#### در نهایت می توان به تابع `hmmCalc` اشاره کرد که وظیفه محاسبه حالت ها و احتمال حالات را دارد برای سادگی می توان آن را به ۳ بخش تقسیم کرد

1. چک کردن طول کلمات و بازگشت در صورت خالی بودن لیست همچنین چک کردن این که` "."` در اول جمله نباشد زیرا جمله نمی تواند با `"."` شروع شود

```dart
  if (myWords.isEmpty) {
    return [];
  }
  if (myWords.first == ".") {
    return [];
  }
```

2. محاسبه احتمال اولین کلمه (زیر این کلمه باید در حالت `"subject"` شروع شود محاسبه آن با بقیه حالات متفاوت است)

```dart
  final hmm = HMM();
  List<Path> output = [];
  output.add(
    Path(
      states: ["subject"],
      prob: hmm.getProbWordInState(
        word: myWords[0],
        state: "subject",
      ),
    ),
  );
```

3.در بخش پایانی از دومین کلمه لیست کلمات شروع می کنیم سپس این کلمات را به این صورت حساب می کنیم که ابتدا از مسیر های موجود اخرین حالت را پیدا می کنیم سپس محاسبه می کنیم که آیا با کلمه موجود و حالتی که در آن هستیم می توان به حالت جدیدی راه پیدا کرد یا نه .اگر احتمال آن وجود داشت این مسبر و حالت را اضافه می کنیم همچنین احتمال آن را نیز با احتمال های موجود ضرب می کنیم. این کار را آنقدر ادامه میدهیم تا کلمات به پایان برسند یا در مرحله تعداد مسیر ها صفر شود که نشان دهنده این است که احتمال این حالت وجود ندارد

```dart
  for (var i = 1; i < myWords.length; i++) {
    List<Path> tempOutput = [];
    if (output.isEmpty) {
      break;
    }
    for (var item in output) {
      final x = hmm.findPossibleNextState(
          prevState: item.currentState, word: myWords[i]);
      for (var element in x) {
        tempOutput.add(
          item.copyWith(
            newState: element["state"] as String,
            newProb: element["prob"] as double,
          ),
        );
      }
    }
    output.clear();
    output.addAll(tempOutput);
  }
  return output;
}
```

### محاسبه احتمال کل و بهترین مسبر حالت ها

برای این کار ابتدا `hmmm` محاسبه می کنیم
سپس با از آن جا که احتمال هر مسیر محاسبه شده است با یکبار پیمایش مقدار مجموع و بیشترین محاسبه می شود.

```dart
    final data = hmmCalc(wordList);
    // این متغیر مقدار احتمال بهترین مسبر را نگهداری میکنید
    double maxProb = 0;
    // این متغیر مجموع احتمال این مسبر را نگهداری میکنید
    double sumProb = 0;
    for (var i = 0; i < data.length; i++) {
      maxProb = max(maxProb, data[i].prob);
      sumProb += data[i].prob;
    }
```

#### هرگونه دخل و تصرف بدون اطلاع نویسنده مجاز می باشد
