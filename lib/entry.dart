class ExpenseEntryModel{
  final int id;
  final String mailID;
  final String amount;
  final String category,note,type;
  final String date;

  ExpenseEntryModel({this.amount, this.date, this.category, this.note, this.type,this.id,this.mailID});

  Map<String, dynamic>toJson()=>{
    "id":id,
    "mailId":mailID,
    "amount":amount,
    "date":date,
    "category":category,
    "note":note,
    "type":type,
  };
}