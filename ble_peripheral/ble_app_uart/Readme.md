This is coming from [the original documentation](http://infocenter.nordicsemi.com/topic/com.nordic.infocenter.sdk5.v12.3.0/ble_sdk_app_nus_eval.html?cp=4_0_7_4_2_2_19) except at the end for the *Testing*, *Debugging* and *Notes* sections.


### UART/Serial Port Emulation over BLE
*`This example requires one of the following SoftDevices: S130, S132`*

**Important**: Before you run this example, make sure to [program the SoftDevice](http://infocenter.nordicsemi.com/topic/com.nordic.infocenter.sdk5.v12.3.0/getting_started_softdevice.html#getting_started_sd).

The Nordic UART Service (NUS) Application is an example that emulates a serial port over BLE. In the example, Nordic Semiconductor's development board serves as a peer to the phone application "nRF UART", which is available for iOS from App Store and for Android from Google Play. In addition, the example demonstrates how to use a proprietary (vendor-specific) service and characteristics with the SoftDevice.

The application includes one service: the Nordic UART Service. The 128-bit vendor-specific UUID of the Nordic UART Service is 6E400001-B5A3-F393-E0A9-E50E24DCCA9E (16-bit offset: 0x0001).

This service exposes two characteristics: one for receiving and one for transmitting (as seen from the nRF5 application).

- TX Characteristic (UUID: 6E400002-B5A3-F393-E0A9-E50E24DCCA9E)
If the peer has enabled notifications for the TX Characteristic, the application can send data to the peer as notifications. The application will transmit all data received over UART as notifications.
- RX Characteristic (UUID: 6E400003-B5A3-F393-E0A9-E50E24DCCA9E)
The peer can send data to the device by writing to the RX Characteristic of the service. ATT Write Request or ATT Write Command can be used. The received data is sent on the UART interface.

#### Important code lines

The following sections describe some important parts of the example code.

Adding proprietary service and characteristics
The initialization of the proprietary service and its characteristics is done in ble_nus.c.

The Nordic UART Service is added to the SoftDevice as follows:

```c
// Add a custom base UUID.
err_code = sd_ble_uuid_vs_add(&nus_base_uuid, &p_nus->uuid_type);
VERIFY_SUCCESS(err_code);
ble_uuid.type = p_nus->uuid_type;
ble_uuid.uuid = BLE_UUID_NUS_SERVICE;
// Add the service.
err_code = sd_ble_gatts_service_add(BLE_GATTS_SRVC_TYPE_PRIMARY,
                                    &ble_uuid,
                                    &p_nus->service_handle);
```
The RX characteristic is added to the SoftDevice as shown in the code below. The read and write permissions of the characteristic and its CCCD are set as open, which means that there are no security restrictions on this characteristic. The type of the UUID (ble_uuid.type) is the value that was returned in the call to sd_ble_uuid_vs_add(). The TX characteristic is added in a similar way.

```c
ble_gatts_char_md_t char_md;
ble_gatts_attr_md_t cccd_md;
ble_gatts_attr_t    attr_char_value;
ble_uuid_t          ble_uuid;
ble_gatts_attr_md_t attr_md;
memset(&cccd_md, 0, sizeof(cccd_md));
BLE_GAP_CONN_SEC_MODE_SET_OPEN(&cccd_md.read_perm);
BLE_GAP_CONN_SEC_MODE_SET_OPEN(&cccd_md.write_perm);
cccd_md.vloc = BLE_GATTS_VLOC_STACK;
memset(&char_md, 0, sizeof(char_md));
char_md.char_props.notify = 1;
char_md.p_char_user_desc  = NULL;
char_md.p_char_pf         = NULL;
char_md.p_user_desc_md    = NULL;
char_md.p_cccd_md         = &cccd_md;
char_md.p_sccd_md         = NULL;
ble_uuid.type = p_nus->uuid_type;
ble_uuid.uuid = BLE_UUID_NUS_RX_CHARACTERISTIC;
memset(&attr_md, 0, sizeof(attr_md));
BLE_GAP_CONN_SEC_MODE_SET_OPEN(&attr_md.read_perm);
BLE_GAP_CONN_SEC_MODE_SET_OPEN(&attr_md.write_perm);
attr_md.vloc    = BLE_GATTS_VLOC_STACK;
attr_md.rd_auth = 0;
attr_md.wr_auth = 0;
attr_md.vlen    = 1;
memset(&attr_char_value, 0, sizeof(attr_char_value));
attr_char_value.p_uuid    = &ble_uuid;
attr_char_value.p_attr_md = &attr_md;
attr_char_value.init_len  = sizeof(uint8_t);
attr_char_value.init_offs = 0;
attr_char_value.max_len   = BLE_NUS_MAX_RX_CHAR_LEN;
return sd_ble_gatts_characteristic_add(p_nus->service_handle,
                                        &char_md,
                                        &attr_char_value,
                                        &p_nus->rx_handles);
```

#### Initializing UART

The initialization of the application and the handling of data sent and received through BLE and UART are done in main.c.

The UART initialization is done as shown in the code below. The code segment uses the UART module that is provided in the SDK to perform the UART configuration. Note that app_uart_comm_params_t configures the application to use hardware flow control. Therefore, RTS_PIN_NUMBER and CTS_PIN_NUMBER are used as Ready-to-Send and Clear-to-Send pins, respectively.

```c
static void uart_init(void)
{
    uint32_t                     err_code;
    const app_uart_comm_params_t comm_params =
    {
        RX_PIN_NUMBER,
        TX_PIN_NUMBER,
        RTS_PIN_NUMBER,
        CTS_PIN_NUMBER,
        APP_UART_FLOW_CONTROL_DISABLED,
        false,
        UART_BAUDRATE_BAUDRATE_Baud115200
    };
    APP_UART_FIFO_INIT( &comm_params,
                       UART_RX_BUF_SIZE,
                       UART_TX_BUF_SIZE,
                       uart_event_handle,
                       APP_IRQ_PRIORITY_LOWEST,
                       err_code);
    APP_ERROR_CHECK(err_code);
}
```
#### Handling data received over BLE

When initializing the service in the services_init() function, the application passes the function nus_data_handler, which is used for handling the received data. When the Nordic UART Service indicates that data has been received over BLE from the peer, the same data is relayed to the UART. The nus_data_handler function is implemented as follows:

```c
static void nus_data_handler(ble_nus_t * p_nus, uint8_t * p_data, uint16_t length)
{
    for (uint32_t i = 0; i < length; i++)
    {
        while (app_uart_put(p_data[i]) != NRF_SUCCESS);
    }
    while (app_uart_put('\r') != NRF_SUCCESS);
    while (app_uart_put('\n') != NRF_SUCCESS);
}
```

#### Handling data received over UART
Data that is received from the UART undergoes certain checks before it is relayed to the BLE peer using the Nordic UART Service. The code shown below is part of the app_uart event handler, which is called every time a character is received over the UART. Received characters are buffered into a string until a new line character is received or the size of the string exceeds the limit defined by NUS_MAX_DATA_LENGTH. When one of these two conditions is met, the string is sent over BLE using the ble_nus_send_string function.

```
Note
By default, the macro NUS_MAX_DATA_LENGTH is set to the maximum size of a notification packet (BLE_ATT_MTU - 3). This is the maximum value for NUS_MAX_DATA_LENGTH, which should not be exceeded.
```

```c
void uart_event_handle(app_uart_evt_t * p_event)
{
    static uint8_t data_array[BLE_NUS_MAX_DATA_LEN];
    static uint8_t index = 0;
    uint32_t       err_code;
    switch (p_event->evt_type)
    {
        case APP_UART_DATA_READY:
            UNUSED_VARIABLE(app_uart_get(&data_array[index]));
            index++;
            if ((data_array[index - 1] == '\n') || (index >= (BLE_NUS_MAX_DATA_LEN)))
            {
                err_code = ble_nus_string_send(&m_nus, data_array, index);
                if (err_code != NRF_ERROR_INVALID_STATE)
                {
                    APP_ERROR_CHECK(err_code);
                }
                index = 0;
            }
            break;
        case APP_UART_COMMUNICATION_ERROR:
            APP_ERROR_HANDLER(p_event->data.error_communication);
            break;
        case APP_UART_FIFO_ERROR:
            APP_ERROR_HANDLER(p_event->data.error_code);
            break;
        default:
            break;
    }
}
```


#### Testing

1) Download and install [Termite](https://www.compuphase.com/software_termite.htm)
*Note: I couldn't get it working using Putty*
2) Connect the board by USB, open the **Device Manager**, scroll down to **Ports (COM & LPT)** and locate the COM number
3) Flash the SoftDevice and the program to the target board using the task runner in VS Code
4) Connect to COM port using Termite with the following configuration:
   - Baud rate: 115200
   - 8 data bits
   - 1 stop bit
   - No parity
   - HW flow control: None
5) Connect with your smartphone using the [nRF UART v2.0 app](https://play.google.com/store/apps/details?id=com.nordicsemi.nrfUARTv2)
6) Send message from Termite and from your smartphone. Messages are transfered

#### Debugging

It is possible to debug using Cortex Debug.

Every time a message is received the *uart_event_handle* function is called.
It then calls the *ble_nus_string_send* function. 

Set  a breakpoint inside this function, send a message through UART and observe the value of the *p_string* parameter.

#### Notes

In debugging mode the nRF UART Android app refuses to connect to the board. Therefore when a message is sent using Termite, the *ble_nus_string_send* function returns *NRF_ERROR_INVALID_STATE*