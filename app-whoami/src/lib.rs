use spin_sdk::http::{IntoResponse, Request, Response};
use spin_sdk::{http_component, variables};

/// A simple Spin HTTP component.
#[http_component]
fn handle_app_whoami(req: Request) -> anyhow::Result<impl IntoResponse> {
    println!("Handling request to {:?}", req.header("spin-full-url"));

    let name = variables::get("pod_name")?;
    let namespace = variables::get("pod_namespace")?;
    let uid = variables::get("pod_uid")?;
    let ip = variables::get("pod_ip")?;
    let node_name = variables::get("node_name")?;
    let host_ip = variables::get("host_ip")?;

    let response = format!(
        "
        <html>
        <body>
        <ul>
            <li>Pod Name: {}</li>
            <li>Pod Namespace: {}</li>
            <li>Pod UID: {}</li>
            <li>Node Name: {}</li>
            <li>Pod IP: {}</li>
            <li>Host IP: {}</li>
            </ul>
        </body>
        </html>
            ",
        name, namespace, uid, node_name, ip, host_ip
    );

    Ok(Response::builder()
        .status(200)
        .header("content-type", "text/html")
        .body(response)
        .build())
}
