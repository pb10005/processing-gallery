import java.util.ArrayList;
import java.util.List;

final int WIDTH = 2000; // display width
final int HEIGHT = 1200; // display height
final int PERIOD = 25; // the period of rotation
final int LOOP_NUM = 5;
final int INIT_RADIUS = 150; // the radius of the biggest circle
final int NUM = 200; // the number of circles
final float OFFSET = 20;
final float SCALE = 0.5;
final float TIME_SCALE = 5;

final int interval = 10; // rendering interval
int time = 0; // global time

List<Point> locus0 = new ArrayList<Point>();
List<Point> locus1 = new ArrayList<Point>();

void setup() {
 size(1000, 600);
 noLoop();
}

void draw() {
  scale(SCALE);
  background(#FFFFFF);
  
  FourierCircle c0 = new SquareWave(WIDTH / 2, HEIGHT / 4, 1, time / interval, INIT_RADIUS);
  FourierCircle c1 = new TriangleWave(WIDTH / 2, 3 * HEIGHT / 4, 1, time / interval, INIT_RADIUS);
  
  /* draw Y axis */
  stroke(0);
  line(100, OFFSET, 100, HEIGHT / 2 - OFFSET);
  line(100, HEIGHT / 2  + OFFSET, 100, HEIGHT - OFFSET);
  render(c0, locus0);
  render(c1, locus1);
  
  if(time / interval < PERIOD * LOOP_NUM) time++;
  else noLoop();
}
void mousePressed(){
  time = 0;
  locus0.clear();
  locus1.clear();
  loop();
}
void render(FourierCircle c, List<Point> locus) {
  /* render the root circle */
  stroke(0);
  strokeWeight(1);
  drawFC(c);
  FourierCircle tmp = c;
  
  /* render the child circles */
  for(int i=0; i < NUM; i++){
    tmp = tmp.getChild();
    drawFC(tmp);
  }
  strokeWeight(3);
  stroke(#FF0000);
  line(tmp.cx, tmp.cy , 100 + TIME_SCALE * time / interval, tmp.cy);
  locus.add(new Point(100 + TIME_SCALE * time / interval, tmp.cy));
  
  /* lender the wave */
  beginShape();
  stroke(#0000FF);
  for(Point p: locus) {
    p.draw();
  }
  endShape();
}
void drawFC(FourierCircle c){
  ellipse(c.cx, c.cy, 2 * c.r, 2 * c.r);
  line(c.cx, c.cy, c.px, c.py);
  stroke(0);
  noFill();
}
class Point {
  float x,y;
  public Point(float x, float y) {
    this.x = x;
    this.y = y;
  }
  void draw() {
    vertex(x, y);
  }
}
abstract class FourierCircle {
  final float R0;
  float cx, cy, r, n, px, py;
  int time;
  public FourierCircle(float cx, float cy, float n ,int time, float r) {
    this.cx = cx;
    this.cy = cy;
    this.n = n;
    this.R0 = r;
    this.r = r * r0() / radiusRatio(n);
    this.time = time;
    
    px = this.cx + this.r * cos(2 * PI * freqRatio(n) * time / PERIOD);
    py = this.cy + sign(n) * this.r * sin(2 * PI * freqRatio(n) * time / PERIOD);
  }
  /* abstract methods */
  public abstract float r0();
  public abstract float sign(float n);
  public abstract float freqRatio(float n);
  public abstract float radiusRatio(float n);
  public abstract FourierCircle getChild();
}
class SquareWave extends FourierCircle {
  /* square wave */
  public SquareWave(float cx, float cy, float n ,int time, float r) {
    super(cx, cy, n , time, r);
  }
  public float r0() {
    return 4 / PI;
  }
  public float sign(float n) {
    return 1;
  }
  public float freqRatio(float n) {
    return 2 * n - 1;
  }
  public float radiusRatio(float n) {
    return 2 * n - 1;
  }
  public SquareWave getChild() {
    return new SquareWave(px, py, n + 1 ,this.time, R0);
  }
}
class TriangleWave extends FourierCircle {
  /* triangle wave */
  public TriangleWave(float cx, float cy, float n ,int time, float r) {
    super(cx, cy, n , time, r);
  }
  public float r0() {
    return 8 / PI / PI;
  }
  public float sign(float n) {
    return n % 2 == 1 ? 1: -1;
  }
  public float freqRatio(float n) {
    return 2 * n - 1;
  }
  public float radiusRatio(float n) {
    return (2 * n - 1) * (2 * n - 1);
  }
  public TriangleWave getChild() {
    return new TriangleWave(px, py, n + 1 ,this.time, R0);
  }
}
