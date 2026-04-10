class ElectricDigitalSketchExeception implements Exception{

  final String message;
  final StackTrace? stackTrace;

  ElectricDigitalSketchExeception(this.message, [this.stackTrace]);

  @override
  String toString() {
    if(stackTrace == null){
      return '$runtimeType: $message\n$stackTrace';
    }
    return '$runtimeType: $message';
  }

}