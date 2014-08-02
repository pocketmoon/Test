public class secondApplet extends PApplet {

  String [] mess= { "", "", "", "", "" ,"", "", "", "", "",
                    "", "", "", "", "" ,"", "", "", "", ""};

  public void setup() {
    size(320, 400);
    noLoop();
  }

  public void setText(String s)
  {
    for (int i=0;i<19;i++)
      mess[i] = mess[i+1];
    mess[19] = s;
  }

  public void draw() {
    background(30);
    for (int i=0;i<=19;i++)
      text('>' + mess[i], 5, 10+i*14);
  }
}

public class PFrame extends JFrame {

  public void setText(String mess)
  {
    s.setText(mess);
    s.redraw();
  }

  public PFrame() {

    setBounds(0, 0, 320, 360);
    s = new secondApplet();
    add(s);
    s.init();
    println("birh");
    show();
  }
}

