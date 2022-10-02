class State {
  final int id;
  final String state;

  State(this.id, this.state);

  factory State.fromJson(Map<String, dynamic> json) {
    State prod = State(json["id"], json["state"]);

    return prod;
  }
}