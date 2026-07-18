let port = null;
let writer = null;
let reader = null;


async function connectSerial() {

    try {

        port = await navigator.serial.requestPort();

        await port.open({
            baudRate: 9600,
            dataBits: 8,
            stopBits: 1,
            parity: "none",
        });


        writer = port.writable.getWriter();


        const info = port.getInfo();


        return {
            success: true,
            port: `VID:${info.usbVendorId ?? "-"} PID:${info.usbProductId ?? "-"}`,
            message: "Machine Connected"
        };


    } catch (e) {

        return {
            success: false,
            message: e.toString()
        };

    }
}



async function writeSerial(data) {

    try {

        if (!writer) {

            return {
                success: false,
                message: "No Serial Port Connected"
            };

        }


        await writer.write(new Uint8Array(data));


        return {
            success: true,
            message: "Write Successfully"
        };


    } catch (e) {

        return {
            success: false,
            message: e.toString()
        };

    }

}


async function disconnectSerial() {

    try {

        // Stop reading
        if (reader) {
            await reader.cancel();
            reader.releaseLock();
            reader = null;
        }


        // Release writer
        if (writer) {
            writer.releaseLock();
            writer = null;
        }


        // Close serial port
        if (port) {
            await port.close();
            port = null;
        }


        return {
            success: true,
            message: "Machine Disconnected"
        };


    } catch (e) {

        return {
            success: false,
            message: e.toString()
        };

    }

}

async function readSerial() {


    try {


        if (!port) {

            return {
                success: false,
                message: "No Port"
            };

        }


        if (!reader) {

            reader = port.readable.getReader();

        }



        const result = await Promise.race([

            reader.read(),

            new Promise(resolve =>
                setTimeout(
                    () => resolve({ timeout: true }),
                    3000
                )
            )

        ]);



        if (result.timeout) {

            return {
                success: false,
                message: "Timeout - No machine response"
            };

        }



        const { value, done } = result;



        if (done) {

            return {
                success: false,
                message: "Reader closed"
            };

        }



        let hex = Array.from(value)
            .map(
                b => b
                    .toString(16)
                    .padStart(2, "0")
                    .toUpperCase()
            )
            .join(" ");



        return {

            success: true,
            data: hex

        };



    } catch (e) {


        return {
            success: false,
            message: e.toString()
        };


    }

}