module dsp.effects;

import dplug.core.nogc;
import dplug.dsp.delayline;
import dplug.dsp.iir;

enum : int
{
    noEffect,
    earlyEffect,
    hallEffect,
    plateEffect,
    tankEffect,
    roomEffect,
    effectCount
}

interface Effect
{
public:
nothrow:
@nogc:
    void processAudio(float[] leftIn, float[] rightIn,
                      float[] leftOut, float[] rightOut,
                      int frames);
    void reset(double sampleRate, int maxFrames);
}

class NoEffect : Effect
{
public:
nothrow:
@nogc:

    this()
    {
    }

    void processAudio(float[] leftIn, float[] rightIn,
                      float[] leftOut, float[] rightOut,
                      int frames)
    {
        leftOut[0..frames] = 0.0;
        rightOut[0..frames] = 0.0;
    }

    void reset(double sampleRate, int maxFrames)
    {
    }
}





final class EarlyEffect: NoEffect
{
public:
nothrow:
@nogc:
  this()
  {
    delayL = [0.0204, 0.0357, 0.0398, 0.0414, 0.0709, 0.0796];
    delayR = [0.0204, 0.0362, 0.0390, 0.0424, 0.0699, 0.0806];
    gainL  = [1.020,   0.818,  0.635,  0.719,  0.267,  0.240];
    gainR  = [1.021,   0.820,  0.633,  0.722,  0.187,  0.243];

    maxDelay = 0.0806; // FIXME! Make reflection pattern configurable

    tapLengthL = 6;
    tapLengthR = 6;

    diffuseAllpassL.initialize();
    diffuseAllpassR.initialize();
  }
  
  override void processAudio(float[] leftIn, float[] rightIn,
                             float[] leftOut, float[] rightOut,
                             int frames)
  {
    debugLog("Dragonfly Reverb 4 - Process Audio!");
    // TODO:
    // * Predelay?
    // * Cross-channel delay/allpass
    // * Width
    // * LPF/HPF

    for (int f = 0; f < frames; f++) {
      delayLineL.feedSample(leftIn[f]);
      delayLineR.feedSample(rightIn[f]);

      float left = 0;
      float right = 0;

      for(int i=0; i<tapLengthL; i++) {
        int delaySamples = cast(int) (delayL[i] * sampleRate);
        left += gainL[i] * delayLineL.sampleFull(delaySamples);
      }
      
      for(int i=0; i<tapLengthR; i++) {
        int delaySamples = cast(int) (delayR[i] * sampleRate);
        right += gainR[i] * delayLineR.sampleFull(delaySamples);
      }

      leftOut[f]  = diffuseAllpassL.nextSample(left,  diffuseAllpassCoefficient);
      rightOut[f] = diffuseAllpassR.nextSample(right, diffuseAllpassCoefficient);
    }
  }

  override void reset(double sampleRate, int maxFrames)
  {
    this.sampleRate = sampleRate;
    int maxDelaySamples = cast(int) (maxDelay * sampleRate);
    delayLineL.resize(maxDelaySamples);
    delayLineR.resize(maxDelaySamples);

    diffuseAllpassCoefficient = biquadRBJAllPass(150, sampleRate);
  }

private:
  float[6] delayL;
  float[6] delayR;
  float[6] gainL;
  float[6] gainR;
  
  float maxDelay;

  int tapLengthL;
  int tapLengthR;

  double sampleRate;

  Delayline!float delayLineL, delayLineR;

  BiquadCoeff diffuseAllpassCoefficient;
  BiquadDelay diffuseAllpassL, diffuseAllpassR;
}

final class HallEffect : NoEffect
{

}

final class PlateEffect : NoEffect
{

}

final class TankEffect : NoEffect
{

}

final class RoomEffect : NoEffect
{

}
