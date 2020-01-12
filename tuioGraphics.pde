final int nb = 80;
float deltaRad = 11;
float rot = 0, rotSpeed = .04;

int mode = 0;

void waveHalo()
{
  rot += rotSpeed;
  rot %= TWO_PI;

  doThis(frameCount/20.0);
  doThis(frameCount/20.0 + PI);
}

void doThis(float omega) { 
  float rad = obj_size*1.2;
  beginShape();
  float deltaTheta = 0;
  int nbCycles = 8;
  float spreadAngle = 1.8;
  for (int i = 0; i <= nb; i ++) {
    float theta = i * TWO_PI/nb;
    float dr = (theta - rot);
    if (dr > PI) {
      dr = TWO_PI-dr;
    } else if (dr < -PI) {
      dr = TWO_PI+dr;
    }

    if (abs(dr) > spreadAngle) {
      deltaTheta = 0;
    } else {
      deltaTheta = map(abs(dr), 0, spreadAngle, 1, 0);
    }

    float deltaRadCoeff = deltaTheta * cos(omega + map(i, 0, nb, 0, nbCycles*TWO_PI));
    if (mode == 0) {
      float r = rad + deltaRad * deltaRadCoeff; 
      vertex(r * cos(theta), r * sin(theta));
    } else if (mode == 1) {
      float x, y;
      if (i < nb/4) {
        deltaRadCoeff *= cos(map(i, 0, nb/4, -PI/2, PI/2));
        x = map(i, 0, nb/4, -rad, rad);
        y = -rad + deltaRadCoeff * deltaRad;
      } else if (i < nb/2) {
        deltaRadCoeff *= cos(map(i, nb/4, nb/2, -PI/2, PI/2));
        x = rad + deltaRadCoeff * deltaRad;
        y = map(i, nb/4, nb/2, -rad, rad);
      } else if (i < 3*nb/4) {
        deltaRadCoeff *= cos(map(i, nb/2, 3*nb/4, -PI/2, PI/2));
        x = map(i, nb/2, 3*nb/4, rad, -rad);
        y = rad + deltaRadCoeff * deltaRad;
      } else {
        deltaRadCoeff *= cos(map(i, 3*nb/4, nb, -PI/2, PI/2));
        x = -rad + deltaRadCoeff * deltaRad;
        y = map(i, 3*nb/4, nb, rad, -rad);
      }
      vertex(x, y);
    }
  } 
  endShape();
}

void sineTo(int x1, int y1, int x2, int y2, float freq, float amp)
{

  PVector p1 = new PVector(x1, y1);
  PVector p2 = new PVector(x2, y2);

  float d = PVector.dist(p1, p2);
  float a = atan2(p2.y-p1.y, p2.x-p1.x);
  noFill();
  pushMatrix();
  translate(p1.x, p1.y);
  rotate(a);
  beginShape();
  for (float i = 0; i <= d; i += 1) 
  {
    vertex(i, sin(i*TWO_PI*freq/d)*amp);
  }
  endShape();
  popMatrix();
}

void squareTo(int x1, int y1, int x2, int y2, float freq, float amp)
{
  PVector p1 = new PVector(x1, y1);
  PVector p2 = new PVector(x2, y2);
  float d = PVector.dist(p1,p2);
  float a = atan2(p2.y-p1.y,p2.x-p1.x);
  noFill();
  pushMatrix();
    translate(p1.x,p1.y);
    rotate(a);
    beginShape();
      line(0,0,0,amp);
      for (float i = 0; i <= d; i += 1) {
        vertex(i,sign(sin(i*TWO_PI*freq/d))*amp);
      }
      line(d,-amp,d,0);
    endShape();
  popMatrix();
}

float sign(float x) //signum equilvalent helper function for squareTo
{
  float y; 
  if(x>=0)
  {
    y=1;
  }
  else y=-1;
  
  return y;
}

void sawToothTo(int x1, int y1, int x2, int y2, float freq, float amp)
{
  PVector p1 = new PVector(x1, y1);
  PVector p2 = new PVector(x2, y2);
  float d = PVector.dist(p1,p2);
  float a = atan2(p2.y-p1.y,p2.x-p1.x);
  noFill();
  pushMatrix();
    translate(p1.x,p1.y);
    rotate(a);
    beginShape();
      for (float i = 0; i <= d; i += 1) 
      {
        vertex(i,(-2*amp)/PI*atan(1/tan((i*PI)/(2*PI*freq/d))));
      }
    endShape();
  popMatrix();
}

void triangleTo(int x1, int y1, int x2, int y2, float freq, float amp)
{
  PVector p1 = new PVector(x1, y1);
  PVector p2 = new PVector(x2, y2);
  float d = PVector.dist(p1,p2);
  float a = atan2(p2.y-p1.y,p2.x-p1.x);
  noFill();
  pushMatrix();
    translate(p1.x,p1.y);
    rotate(a);
    beginShape();
      for (float i = 0; i <= d; i += 1) 
      {
        vertex(i,(2*amp)/PI*asin(sin((2*i*PI)/(2*PI*freq/d))));
      }
    endShape();
  popMatrix();
}

//void drawShockWave()
//{
//  float setTime=TuioTime.getSessionTime().getSeconds();
//  float shockRad=centerRad;
//  stroke(255,255,255,10); 
//  strokeWeight(50); 
//  for(int i=0;i<2000;i++)
//  {
//    ellipse(centerX,centerY,shockRad,shockRad);
//    shockRad+=.001;
//  }
  
//}
 
