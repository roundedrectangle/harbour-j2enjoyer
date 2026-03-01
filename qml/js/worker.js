Qt.include("dom-parser.js")

var host, pagePath

function getNodeBackgroundFromStyle(node) {
    var style = node.getAttribute('style')
    if (!style) return ''
    return parseUrl(new RegExp(/(\/[a-zA-Z0-9]+)+\.[a-z]+/g).exec(style)[0])
}

function parseUrl(url) {
    if (url.indexOf('//') === 0) return 'https:' + url
    if (url.indexOf('/') === 0) return host + url
    return url
}

function s(a) {
    return a.trim()
        .replace(/&nbsp;/g, ' ') // non-break space, currently just replace with normal space
        .replace(/&amp;/g, '&')
        .replace(/&lt;/g, '<')
        .replace(/&quot;/g, '"')
        .replace(/&#039;/g, "'")
        .replace(/&#x27;/g, "'")
}

function n(x) {
    return x.replace(/\D+/g, '')
}

function send(t, v) {
    WorkerScript.sendMessage({t: t, v: v})
}

WorkerScript.onMessage = function(message) {
    host = message.host.replace(new RegExp(/\/$/g), '') // trim trailing slashes
    pagePath = '/' + message.pagePath.replace(new RegExp(/^\//g), '')
    send('url', host + pagePath)

    var request = new XMLHttpRequest();

    request.onreadystatechange = function() {
        if (request.readyState === XMLHttpRequest.DONE) {
            if (request.status >= 200 && request.status <= 300) {
                try {
                    var dom = new Dom(request.response)
                    //send('productTitle', request.respose)

                    var number = dom.getElementsByClassName('cf-backertotal')[0]
                    send('number', n(number.textContent()))
                    send('total', n(number.parentNode.childNodes
                                    .map(function(x) { return x.nodeType === NodeType.text ? x.text : '' })
                                    .join('')
                                    .replace(/\x20+/g, ' ')
                                    ))
                    send('percentage', n(dom.getElementsByClassName('cf-percent-text')[0].textContent()))
                    send('endTime', n(dom.getElementsByClassName('cf-time-left')[0].getAttribute('data-end-time')))
                    send('productTitle', dom.getElementsByTagName('h1')[0].textContent())

                    var images = []
                    dom.getElementsByClassName('image-magnify-lightbox').forEach(function(node) {
                        images.push(parseUrl(node.getAttribute('src')))
                    })
                    send('images', images)

                    send('loaded')
                } catch (e) {
                    send('error', e)
                }
            } else
                send('error2', request.status)
        }
    }

    request.open('GET', host + pagePath)
    request.send()
}
