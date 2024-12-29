export default class RecordItem{
  //ID
  id:number;
  //攻略名称
  name:ResourceStr;
  //用户名称
  userid:ResourceStr;
  //攻略图片
  image:ResourceStr;
  //攻略文字
  text:ResourceStr;

  time:ResourceStr;

  constructor(id:number,name:ResourceStr,userid:ResourceStr,image:ResourceStr,text:ResourceStr,time:ResourceStr){
    this.id = id;
    this.name = name;
    this.userid = userid;
    this.image = image;
    this.text = text;
    this.time = time;
  }
}

