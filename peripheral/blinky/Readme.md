### Blinky Example
The Blinky Example shows how to configure the GPIO pins as outputs using the BSP module. These outputs can then be used to drive LEDs, as in this example.

![Illustration of the Blinky Example workflow](http://infocenter.nordicsemi.com/topic/com.nordic.infocenter.sdk5.v12.3.0/blinky.svg "Illustration of the Blinky Example workflow")
Illustration of the Blinky Example workflow

When the application starts, some GPIO pins are configured as outputs to drive the LEDs. The application then loops while toggling the state of one of the LEDs every 500 milliseconds.

You can use this example without a SoftDevice. Alternatively, you can run it with SoftDevice S130 or S132.

You can find the source code and the project file of the example in the following folder: `<InstallFolder>\examples\peripheral\blinky`

### Testing
Test the Blinky Example application by performing the following steps:
1) Compile and program the application.
2) Observe that the LEDs are blinking.