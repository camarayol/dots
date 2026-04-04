function proxy
    set -gx http_proxy  http://127.0.0.1:10808
    set -gx https_proxy http://127.0.0.1:10808
    set -gx all_proxy   socks5://127.0.0.1:10808

    set -gx HTTP_PROXY  $http_proxy
    set -gx HTTPS_PROXY $https_proxy
    set -gx ALL_PROXY   $all_proxy
end

function unproxy
    set -e http_proxy
    set -e https_proxy
    set -e all_proxy
    set -e HTTP_PROXY
    set -e HTTPS_PROXY
    set -e ALL_PROXY
end
