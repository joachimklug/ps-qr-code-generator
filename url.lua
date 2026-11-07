info = {
    id = "hello",
    type = "project.plugin",
    title = "QR Code Generator - URL",
    menu = "Generate-QR/URL",
    params = {
        { name = "url", label = "URL", type = "string", default = "https://example.com" }
    }
}

function execute(opts)
    api.project:add_object {
        mesh = api.emboss_text {
            font = api.get_default_font(),
            text = opts.url,
            depth = 1
        },
        object_params = { fill_density = "0%" }
    }
end
