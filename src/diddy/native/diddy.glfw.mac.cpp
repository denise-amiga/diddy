/*
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#include <time.h>
#include <math.h>
extern gxtkAudio *bb_audio_device;
extern gxtkGraphics *bb_graphics_device;

float diddy_mouseWheel = 0.0f;

#ifdef _glfw3_h_
void diddy_mouseScroll(GLFWwindow *window, double xoffset, double yoffset) {
	diddy_mouseWheel = yoffset;
}
#endif

float diddy_mouseZ() {
	float ret = 0.0f;
#ifdef _glfw3_h_
	ret = diddy_mouseWheel;
	diddy_mouseWheel = 0;
#else
	ret = glfwGetMouseWheel() - diddy_mouseWheel;
	diddy_mouseWheel = glfwGetMouseWheel();
#endif
	return ret;
}

class diddy
{
	public:

	static float mouseZ()
	{
		return diddy_mouseZ();
	}
	
	static void mouseZInit()
	{
#ifdef _glfw3_h_
		glfwSetScrollCallback(BBGlfwGame::GlfwGame()->GetGLFWwindow(), diddy_mouseScroll);
#endif
	}
	
	// only accurate to 1 second 
	static int systemMillisecs() {
		time_t seconds;
		seconds = time (NULL);
		return seconds * 1000;
	}
	
	static void setGraphics(int w, int h)
	{
#ifdef _glfw3_h_
		GLFWwindow *window = BBGlfwGame::GlfwGame()->GetGLFWwindow();
		glfwSetWindowSize(window, w, h);
		
		GLFWmonitor *monitor = glfwGetPrimaryMonitor();
		const GLFWvidmode *desktopMode = glfwGetVideoMode(monitor);
		
		glfwSetWindowPos(window, (desktopMode->width-w)/2,(desktopMode->height-h)/2 );
#else
		glfwSetWindowSize(w, h);
		GLFWvidmode desktopMode;
		glfwGetDesktopMode( &desktopMode );
		glfwSetWindowPos( (desktopMode.Width-w)/2,(desktopMode.Height-h)/2 );
#endif
	}
	
	static void setMouse(int x, int y)
	{
#ifdef _glfw3_h_
		glfwSetCursorPos(BBGlfwGame::GlfwGame()->GetGLFWwindow(), x, y);
#else
		glfwSetMousePos(x, y);
#endif
	}
	
	static void showKeyboard()
	{
	}
	static void launchBrowser(String address, String windowName)
	{
	}
	static void launchEmail(String email, String subject, String text)
	{
	}

	static void startVibrate(int millisecs)
	{
	}
	static void stopVibrate()
	{
	}
	
	static void startGps()
	{
	}
	static String getLatitiude()
	{
		return "";
	}
	static String getLongitude()
	{
		return "";
	}
	static void showAlertDialog(String title, String message)
	{
	}
	static String getInputString()
	{
		return "";
	}
	
	static int seekMusic(int timeMillis)
	{
		gxtkChannel *chan = &(bb_audio_device->channels[32]);
		if(chan && chan->state==1)
		{
			alSourcef(chan->source, AL_SEC_OFFSET, (float)(timeMillis / 1000.0));
		}
		// TODO: check it worked
		return 1;
	}
};
