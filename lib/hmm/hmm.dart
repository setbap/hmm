import 'dart:developer';

List<Path> hmmCalc(List<String> myWords) {
  if (myWords.isEmpty) {
    return [];
  }
  final hmm = HMM();
  List<Path> output = [];
  // var list = hmm.findPossibleNextState(prevState: "subject", word: myWords[0]);
  // for (var item in list) {
  //   output.add(
  //     Path(states: [item["state"] as String], prob: item["prob"] as double),
  //   );
  // }
  output.add(
    Path(
      states: ["subject"],
      prob: hmm.getProbWordInState(
        word: myWords[0],
        state: "subject",
      ),
    ),
  );

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
  log(output.toString());
  return output;
}

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

  @override
  String toString() {
    final pathString = states.join("->");

    return """\n
    ------------------------------
    path : $pathString,
    prob : $prob,
    -------------------------------
    """;
  }
}

class HMM {
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

  double getProbWordInState({
    required String word,
    required String state,
  }) {
    final getStateNumber = stateNumber[state]!;
    return outputProb[word]![getStateNumber];
  }

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
}
