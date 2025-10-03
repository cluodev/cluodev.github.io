server {
    listen ${nginx_port};
    %{ if ssl_enabled }
    listen 443 ssl http2;
    %{ endif }
    
    server_name ${domain_name};
    root ${site_path};
    index index.html;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json
        image/svg+xml;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Static files caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # Handle Astro's routing
    location / {
        try_files $uri $uri/ $uri.html =404;
    }

    # Handle API routes (if any)
    location /api/ {
        try_files $uri $uri/ =404;
    }

    # RSS feed
    location = /rss.xml {
        add_header Content-Type application/rss+xml;
    }

    # Robots.txt
    location = /robots.txt {
        access_log off;
        log_not_found off;
    }

    # Favicon
    location = /favicon.ico {
        access_log off;
        log_not_found off;
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    %{ if ssl_enabled }
    # SSL configuration (placeholder - you'll need to configure SSL certificates)
    # ssl_certificate /etc/ssl/certs/${domain_name}.crt;
    # ssl_certificate_key /etc/ssl/private/${domain_name}.key;
    # ssl_protocols TLSv1.2 TLSv1.3;
    # ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    # ssl_prefer_server_ciphers off;
    %{ endif }

    # Logs
    access_log /var/log/nginx/${domain_name}_access.log;
    error_log /var/log/nginx/${domain_name}_error.log;
}