import { Client } from "@gradio/client";
const clientConfig = {
    uriBase: "http://butts.infinitebutts.com",
};
export function configure(uriBase, hfToken) {
    clientConfig.uriBase = uriBase;
    clientConfig.hfToken = hfToken;
}
async function getClient(statusCallback) {
    statusCallback ?? (statusCallback = (ss) => console.debug(ss));
    return await Client.connect(clientConfig.uriBase, {
        hf_token: `hf_${clientConfig.hfToken}`,
        status_callback: statusCallback,
        events: ["status", "data", "log"]
    });
}
export async function toBlob(imageUrl) {
    if (typeof imageUrl != "string")
        return imageUrl;
    const response_0 = await fetch(imageUrl);
    return await response_0.blob();
}
// export async function generateCanny(srcImage: string | Blob, data: CannyConfig, callbackObj?: DotNet.DotNetObject | StatusCallback): Promise<Blob> {
// 	const srcImageBlob = await toBlob(srcImage)
// 	const args = [
// 		srcImageBlob, 	// blob in 'Source' Image component		
// 	].concat(toArgs(data));
// 	const result = await run<Blob>("/generate_canny", args,callbackObj);
// 	console.log(result);
// 	return <Blob>result.data[0];
// }
function toArgs(data) {
    return [
        data?.controlImgSize ?? 768, // number  in 'Target Size' Number component		
        data?.scale ?? true, // boolean  in 'Scale?' Checkbox component		
        data?.scaleUp ?? true, // boolean  in 'Scale Up?' Checkbox component		
        data?.crop ?? true, // boolean  in 'Crop?' Checkbox component		
        data?.scaleDimension, // string (Option from: [('SHORT', 'SHORT'), ('LONG', 'LONG')]) in 'Scale Dimension' Dropdown component		
        data?.cannyLow ?? 100, // number  in 'Canny Low' Number component		
        data?.cannyHigh ?? 200, // number  in 'Canny High' Number component
    ];
}
export async function saveConfig(data) {
    const app = await getClient();
    const result = await run("/save_config", [
        data?.numOutputs,
        data?.imgSize, // number  in 'Image Size' Number component
        data?.numSteps, // number  in 'Num. Steps' Number component
        data?.controlScale, // number  in 'Control Scale' Number component
    ].concat(toArgs(data.cannyConfig)));
    console.log(result);
    return result;
}
//export interface PredictReturn<T> {
//	data: T[],
//	endpoint: string,
//	fn_index: number,
//	time: object,
//	type: string,
//	event_data: unknown
//}
export async function resetConfig(uriBase) {
    const result = await run("/reset_config", []);
    console.log(result);
    return result;
}
function toStatusCallback(callbackObj) {
    if (!callbackObj)
        return () => null;
    if (typeof callbackObj == "function")
        return callbackObj;
    return () => null;
}
function disposeStatusCallback(callbackObj) {
    if (!callbackObj)
        return;
}
export async function generate(srcImage, prompt, negative, data, callbackObj) {
    try {
        //		const canny = await generateCanny(srcImage, data?.cannyConfig, callbackObj);
        return await generatePromptImage(srcImage, prompt, negative, data, callbackObj);
    }
    finally {
        disposeStatusCallback(callbackObj);
    }
}
export async function generatePromptImage(cannyImage, prompt, negative, data, callbackObj) {
    const cannyBlob = await toBlob(cannyImage);
    try {
        const result = await run('/generate_prompt', [
            cannyBlob, // blob in 'ControlNet Output' Image component		
            prompt, // string  in 'Prompt' Textbox component		
            negative, // string  in 'Negative Prompt' Textbox component		
            data?.numOutputs ?? 1,
            data?.imgSize ?? 1024, // number  in 'Image Size' Number component		
            data?.numSteps ?? 20, // number  in 'Num. Steps' Number component		
            data?.controlScale ?? 0.45, // number  in 'Control Scale' Number component
        ], callbackObj);
        console.log(result);
        return result.data.filter(x => x != null).map(x => x.url);
    }
    catch (e) {
        console.error(e);
    }
}
async function run(endpoint, data, callbackObj, event_data) {
    const connection = await getClient();
    let data_returned = false;
    let status_complete = false;
    let error_sent = false;
    let status_callback = toStatusCallback(callbackObj);
    const submission = await connection.submit(endpoint, data, event_data);
    let result;
    for await (const msg of submission) {
        try {
            if (msg.type === "data") {
                if (status_complete) {
                    submission.cancel();
                    disposeStatusCallback(status_callback);
                }
                data_returned = true;
                return msg;
            }
            if (msg.type == "status") {
                const message = `${msg.time}: ${msg.stage} - ${msg.message}`;
                console.debug(message, msg);
                if (status_callback) {
                    status_callback(msg);
                }
                if (msg.stage === "error") {
                    error_sent = true;
                    disposeStatusCallback(status_callback);
                    throw message;
                }
                if (msg.stage === "complete") {
                    status_complete = true;
                    // if complete message comes after data, resolve here
                    if (data_returned) {
                        //submission.cancel();
                        disposeStatusCallback(status_callback);
                        return result;
                    }
                }
            }
            if (msg.type == "log") {
                console.debug(msg.log, msg);
            }
        }
        catch (e) {
            if (submission && data_returned) {
                //				app.destroy();
                disposeStatusCallback(status_callback);
            }
            if (!data_returned && !status_complete && !error_sent)
                throw e;
        }
    }
}
const gradio = {
    configure,
    generatePromptImage,
    generate,
    resetConfig,
    saveConfig,
    toBlob
};
window.gradio = gradio;
export default gradio;
//# sourceMappingURL=gradio.js.map