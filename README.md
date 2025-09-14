# Inception Projesi: Docker, NGINX, WordPress ve MariaDB Detaylı Rehberi

## İçindekiler

- [Docker Nedir ve Neden Kullanılmalı?](#docker-nedir-ve-neden-kullanılmalı)
- [Konteynerler vs. Sanal Makineler](#konteynerler-vs-sanal-makineler)
- [NGINX Nedir?](#nginx-nedir)
- [TLS/SSL Nedir ve Neden Önemlidir?](#tlsssl-nedir-ve-neden-önemlidir)
- [Sertifikalar Nasıl Çalışır?](#sertifikalar-nasıl-çalışır)
- [WordPress Nedir?](#wordpress-nedir)
- [PHP-FPM ve Önemi](#php-fpm-ve-önemi)
- [MariaDB Nedir?](#mariadb-nedir)
- [Veritabanı Güvenliği](#veritabanı-güvenliği)
- [Docker Compose ve Servis Orkestrasyonu](#docker-compose-ve-servis-orkestrasyonu)
- [Docker Volume'ları ve Veri Kalıcılığı](#docker-volumeları-ve-veri-kalıcılığı)
- [PID 1 Sorunu ve Docker'da Process Yönetimi](#pid-1-sorunu-ve-dockerda-process-yönetimi)

## Docker Nedir ve Neden Kullanılmalı?

Docker, yazılım uygulamalarını hızlı bir şekilde oluşturma, test etme ve dağıtma imkanı sağlayan bir konteynerizasyon platformudur. Docker, uygulamaları "konteynerler" adı verilen standartlaştırılmış birimler içinde paketler. Bu konteynerler, uygulamaları çalıştırmak için gereken her şeyi içerir: kod, çalışma zamanı, sistem araçları, sistem kütüphaneleri ve ayarlar.

### Docker'ın Avantajları:

1. **Tutarlılık**: "Benim bilgisayarımda çalışıyor" sorununu ortadan kaldırır; uygulama her ortamda aynı şekilde çalışır.
2. **İzolasyon**: Her uygulama kendi kaynakları ve bağımlılıklarıyla izole edilmiş bir ortamda çalışır.
3. **Verimlilik**: Sanal makinelere göre daha az kaynak kullanır ve daha hızlı başlatılır.
4. **Ölçeklenebilirlik**: Uygulamaları kolayca ölçeklendirmeye olanak tanır.
5. **CI/CD Entegrasyonu**: Sürekli entegrasyon ve sürekli dağıtım süreçlerini kolaylaştırır.

Docker, altyapı yönetimini basitleştirerek yazılım geliştirme süreçlerini hızlandırır ve uygulamaların taşınabilirliğini artırır.

## Konteynerler vs. Sanal Makineler

Konteynerler ve sanal makineler (VM) arasındaki farkı anlamak önemlidir:

### Sanal Makineler:
- Her VM kendi işletim sistemini çalıştırır
- Daha fazla kaynak tüketir (RAM, disk alanı)
- Tam izolasyon sağlar
- Başlatılması daha uzun sürer
- Her VM için tam bir işletim sistemi lisansı gerekebilir

### Konteynerler:
- Host işletim sisteminin çekirdeğini paylaşır
- Daha az kaynak kullanır
- İşletim sistemi düzeyinde sanallaştırma
- Saniyeler içinde başlatılabilir
- Daha hafif ve taşınabilir

Bu projede konteynerler kullanmamızın nedeni, hafiflik, hız ve taşınabilirlik avantajlarını elde etmektir.

## NGINX Nedir?

NGINX (Engine-X olarak okunur), yüksek performanslı bir web sunucusu, ters proxy ve yük dengeleyicisidir. Apache gibi geleneksel web sunucularından farklı olarak, olay tabanlı bir mimari kullanır ve eşzamanlı bağlantıları çok daha verimli bir şekilde işler.

### NGINX'in Temel Özellikleri:

1. **Yüksek Performans**: Binlerce eşzamanlı bağlantıyı düşük bellek kullanımıyla işleyebilir.
2. **Ters Proxy**: İstemci isteklerini arka uç sunuculara yönlendirir ve yanıtları istemciye döndürür.
3. **Yük Dengeleme**: Trafiği birden çok sunucu arasında dağıtarak yükü dengeler.
4. **SSL/TLS Sonlandırma**: Şifreli bağlantıları işler ve backend sunucularla güvenli iletişim sağlar.
5. **Statik İçerik Sunumu**: HTML, CSS, JavaScript gibi statik dosyaları verimli bir şekilde sunar.

Bu projede NGINX, WordPress web sitesine güvenli erişim sağlamak için kullanılmaktadır. HTTPS trafiğini işler, TLS/SSL şifrelemeyi yönetir ve istekleri arka uçtaki WordPress uygulamasına yönlendirir.

## TLS/SSL Nedir ve Neden Önemlidir?

TLS (Transport Layer Security) ve onun öncülü olan SSL (Secure Sockets Layer), internet üzerindeki iletişimi güvenli hale getirmek için kullanılan şifreleme protokolleridir. Bu protokoller sayesinde:

1. **Veri Gizliliği**: İletilen veriler şifrelenir, böylece üçüncü taraflar tarafından okunamaz.
2. **Veri Bütünlüğü**: Verinin iletim sırasında değiştirilip değiştirilmediği kontrol edilir.
3. **Kimlik Doğrulama**: Bağlandığınız sunucunun gerçekten olduğunu iddia ettiği sunucu olduğunu doğrular.

### Neden TLS 1.2 veya TLS 1.3 Kullanmalıyız?

- **TLS 1.0 ve 1.1**: Güvenlik açıkları barındırdığından kullanımdan kaldırılmıştır.
- **TLS 1.2**: 2008'de tanıtıldı, günümüzde hala güvenli ve yaygın olarak kullanılıyor.
- **TLS 1.3**: 2018'de tanıtıldı, daha güvenli, daha hızlı ve daha basit.

Bu projede, sadece TLS 1.2 ve TLS 1.3 kullanımına izin vererek güvenliği en üst düzeye çıkarıyoruz.

## Sertifikalar Nasıl Çalışır?

SSL/TLS sertifikaları, web sitelerinin kimliğini doğrulamak ve güvenli bağlantılar kurmak için kullanılır. Bir SSL/TLS sertifikası şunları içerir:

1. **Açık Anahtar**: Veriyi şifrelemek için kullanılır.
2. **Dijital İmza**: Güvenilir bir Sertifika Otoritesi (CA) tarafından verilir.
3. **Sertifika Sahibi Bilgileri**: Alan adı, organizasyon, konum gibi bilgiler.
4. **Geçerlilik Süresi**: Sertifikanın ne zaman sona ereceği.

### Sertifika Türleri:

- **Domain Validated (DV)**: Sadece alan adı sahipliği doğrulanır.
- **Organization Validated (OV)**: Alan adı ve organizasyon bilgileri doğrulanır.
- **Extended Validation (EV)**: En kapsamlı doğrulama süreci ile verilir.
- **Wildcard Sertifikaları**: Bir ana alan adı ve tüm alt alan adlarını kapsar.
- **Self-Signed (Kendinden İmzalı)**: CA tarafından imzalanmamış, genellikle test amaçlı kullanılır.

Bu projede, geliştirme ortamı için kendinden imzalı bir sertifika kullanıyoruz.

## WordPress Nedir?

WordPress, dünyanın en popüler içerik yönetim sistemidir (CMS). İnternet sitelerinin yaklaşık %40'ı WordPress altyapısı kullanmaktadır. PHP dilinde yazılmış ve MySQL/MariaDB veritabanı kullanan açık kaynaklı bir yazılımdır.

### WordPress'in Temel Özellikleri:

1. **Kullanım Kolaylığı**: Teknik bilgi gerektirmeden içerik oluşturma ve yönetme.
2. **Eklentiler**: 59.000'den fazla eklenti ile işlevsellik genişletme.
3. **Temalar**: Binlerce ücretsiz ve ücretli tema seçeneği.
4. **SEO Dostu**: Arama motorları için optimize edilmiş yapı.
5. **Topluluk Desteği**: Büyük ve aktif bir geliştirici topluluğu.

WordPress, bloglardan kurumsal sitelere, e-ticaret platformlarından forum sitelerine kadar çeşitli web projelerinde kullanılabilir.

## PHP-FPM ve Önemi

PHP-FPM (FastCGI Process Manager), PHP kodunu çalıştırmak için kullanılan bir FastCGI uygulamasıdır. Geleneksel PHP çalıştırma yöntemlerine göre daha verimli ve ölçeklenebilir bir alternatiftir.

### PHP-FPM'in Avantajları:

1. **Kaynak Yönetimi**: İsteğe bağlı olarak PHP işlemlerini başlatır ve sonlandırır.
2. **İzolasyon**: Her site için ayrı havuzlar oluşturabilir, böylece bir sitedeki sorun diğerlerini etkilemez.
3. **Performans**: Apache mod_php'ye göre daha az kaynak tüketir.
4. **Ölçeklenebilirlik**: Yüksek trafikli siteleri daha iyi yönetir.

PHP-FPM, web sunucusu (NGINX) ile PHP arasında bir arayüz görevi görür. NGINX gelen istekleri alır, PHP dosyalarını içeren istekleri PHP-FPM'e yönlendirir ve PHP-FPM tarafından işlenen yanıtları istemciye iletir.

## MariaDB Nedir?

MariaDB, MySQL'in topluluk tarafından geliştirilen bir çatalıdır (fork). MySQL'in orijinal geliştiricileri tarafından oluşturulmuştur ve MySQL ile yüksek uyumluluk sağlar. Açık kaynaklı bir ilişkisel veritabanı yönetim sistemidir.

### MariaDB'nin MySQL'e Göre Avantajları:

1. **Topluluk Odaklı**: Tamamen açık kaynak ve topluluk tarafından yönetilir.
2. **Performans İyileştirmeleri**: Sorgu optimizasyonları ve depolama motorları ile daha hızlı.
3. **Ek Özellikler**: Gelişmiş replikasyon, saklı yordamlar ve daha fazla depolama motoru.
4. **Güvenlik**: Düzenli güncellemeler ve güvenlik yamaları.

MariaDB, WordPress gibi uygulamaların veritabanı ihtiyaçlarını karşılamak için mükemmel bir seçimdir.

## Veritabanı Güvenliği

Veritabanı güvenliği, web uygulamalarının kritik bir bileşenidir. Bu projede aşağıdaki güvenlik önlemleri alınmıştır:

1. **Şifre Yönetimi**: Parolalar Docker Secrets kullanılarak güvenli bir şekilde saklanır.
2. **En Az Ayrıcalık İlkesi**: Kullanıcılara yalnızca ihtiyaç duydukları izinler verilir.
3. **İzolasyon**: Veritabanı yalnızca Docker ağı içinden erişilebilir.
4. **Root Erişimi Kısıtlaması**: Root kullanıcısı yalnızca yerel erişime izin verir.
5. **Güvenli Başlangıç**: Güvensiz varsayılan ayarlar kaldırılmıştır.

## Docker Compose ve Servis Orkestrasyonu

Docker Compose, birden çok Docker konteynerini tanımlamak ve çalıştırmak için kullanılan bir araçtır. YAML formatında yazılan bir yapılandırma dosyası kullanarak, tüm servis yapılandırmalarını, bağımlılıkları, ağları ve hacimleri tek bir komutla yönetmenize olanak tanır.

### Docker Compose'un Temel Özellikleri:

1. **Servis Tanımları**: Her bir uygulamayı ayrı bir servis olarak tanımlama.
2. **Ağ Yapılandırması**: Servisler arası iletişim için özel ağlar oluşturma.
3. **Hacim Yönetimi**: Veri kalıcılığı için hacimlerin tanımlanması.
4. **Bağımlılık Yönetimi**: Servislerin başlatma sırasını kontrol etme.
5. **Ortam Değişkenleri**: Yapılandırma parametrelerini dışarıdan sağlama.

Bu projede Docker Compose, üç ana servisi (NGINX, WordPress ve MariaDB) tek bir komutla yönetmek için kullanılmaktadır.

## Docker Volume'ları ve Veri Kalıcılığı

Docker konteynerlerinin geçici doğası nedeniyle, verilerinizin kalıcı olması için özel önlemler almanız gerekir. Konteyner silindiğinde, içindeki tüm veriler de silinir. Docker Volume'lar bu sorunu çözmek için tasarlanmıştır.

### Volume'ların Avantajları:

1. **Veri Kalıcılığı**: Konteynerler yeniden oluşturulsa bile veriler korunur.
2. **Veri Paylaşımı**: Konteynerler arasında veri paylaşımına olanak tanır.
3. **Performans**: Bind mount'lara göre daha iyi performans.
4. **Kolay Yedekleme**: Verileri kolayca yedekleme ve taşıma.

Bu projede iki ana volume kullanıyoruz:
- **WordPress Volume**: WordPress dosyalarını (tema, eklenti, medya, vb.) saklar.
- **MariaDB Volume**: Veritabanı dosyalarını saklar.

## PID 1 Sorunu ve Docker'da Process Yönetimi

Linux'ta PID 1 (ilk proses kimliği), özel bir öneme sahiptir. Init sistem olarak bilinen bu proses, diğer tüm proseslerin atası olarak kabul edilir ve özel sorumlulukları vardır:

1. **Sinyal İşleme**: Zombi prosesleri temizler.
2. **Proses Evlatlık Edinme**: Ebeveyn prosesi ölen prosesleri evlat edinir.
3. **Düzgün Kapatma**: Sistem kapatıldığında düzgün kapatma işlemlerini yönetir.

Docker konteynerlerinde, başlatılan ilk proses PID 1 olur ve bu özel sorumlulukları üstlenir. Eğer bu proses bir init sistemi değilse (örneğin bash veya tail -f), zombi prosesler birikebilir ve sinyaller düzgün işlenmeyebilir.

### Doğru PID 1 Yönetimi:

1. **exec Komutu Kullanımı**: Bash betiklerinde son komutu `exec` ile çalıştırarak, o komutun PID 1 olmasını sağlayabiliriz.
2. **Doğrudan Uygulama Çalıştırma**: Init script yerine doğrudan ana uygulamayı ENTRYPOINT olarak çalıştırmak.
3. **Özel Init Sistemleri**: tini, dumb-init gibi hafif init sistemleri kullanmak.

Bu projede, her container'da ana uygulamayı PID 1 olarak çalıştırarak doğru sinyal işleme ve kaynak temizliği sağlıyoruz.

---

Bu proje, modern web uygulaması altyapısının nasıl güvenli, ölçeklenebilir ve taşınabilir bir şekilde oluşturulabileceğini gösteren kapsamlı bir örnektir. Docker, NGINX, WordPress ve MariaDB gibi teknolojileri birleştirerek, tamamen izole edilmiş ancak birlikte çalışan bir sistem oluşturulmuştur.

WordPress container'ı aşağıdaki hata mesajını sürekli olarak gösteriyordu:

```
Error: Error establishing a database connection. This either means that the username and 
password information in your `wp-config.php` file is incorrect or that contact with the 
database server at `mariadb:3306` could not be established. This could mean your host's 
database server is down.
```

### Sorunun Analizi

Sorunun iki ana olası nedeni vardı:

1. **Zamanlama Sorunu**: WordPress servisi, MariaDB veritabanı servisi tamamen hazır olmadan bağlanmaya çalışıyordu.
2. **Yapılandırma Sorunu**: Kullanıcı adı veya şifre gibi kimlik bilgileri doğru şekilde aktarılmamış olabilir.

İnceleme sonucunda, ana sorunun **zamanlama sorunu** olduğu belirlendi. Docker Compose'daki `depends_on` parametresi, container'ın başlamasını bekler ancak içindeki servisin tamamen hazır olmasını beklemez.

## Çözüm Yöntemleri

Sorunun çözümü için iki temel yaklaşım uygulandı:

### 1. Docker Compose'da Healthcheck ile Çözüm

Docker Compose dosyasına healthcheck eklemek, WordPress'in MariaDB servisi tamamen hazır olana kadar beklemesini sağlar:

```yaml
services:
  mariadb:
    # ... diğer yapılandırmalar ...
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 5s
      timeout: 3s
      retries: 5
      
  wordpress:
    # ... diğer yapılandırmalar ...
    depends_on:
      mariadb:
        condition: service_healthy
```

Ancak bu projeye özel olarak healthcheck kullanmak istenmediğinden, alternatif bir çözüm uygulandı.

### 2. WordPress Başlatma Scriptinde Sağlam Bağlantı Kontrol Mekanizması

`wpinit.sh` dosyasına MariaDB'nin hazır olmasını bekleyen gelişmiş bir kontrol mekanizması eklendi:

```bash
# Enhanced robust waiting mechanism for MariaDB
echo ">>> Waiting for MariaDB to be ready..."
MAX_TRIES=60
RETRY_INTERVAL=5

for i in $(seq 1 $MAX_TRIES); do
    echo ">>> Connection attempt $i/$MAX_TRIES..."
    
    # First check if TCP port is open
    if timeout 3 bash -c "</dev/tcp/mariadb/3306" 2>/dev/null; then
        echo ">>> TCP port 3306 is reachable"
        
        # Now check if MySQL service is responding
        if mysqladmin ping -h"mariadb" -u"$WP_DB_USER" -p"$DB_PASS" --silent 2>/dev/null; then
            echo ">>> MariaDB service is responding!"
            
            # Final check - try to query the actual database
            if mysql -h"mariadb" -u"$WP_DB_USER" -p"$DB_PASS" -e "USE $WP_DB_NAME; SELECT 1;" 2>/dev/null; then
                echo ">>> Database connection fully verified!"
                break
            else
                echo ">>> Database exists but can't query it yet..."
            fi
        else
            echo ">>> MariaDB port is open but service not ready..."
        fi
    else
        echo ">>> Waiting for MariaDB TCP port to open..."
    fi
    
    # If we've reached the last attempt, show detailed debug info
    if [ $i -eq $MAX_TRIES ]; then
        echo ">>> WARNING: Maximum connection attempts reached! Debug information:"
        echo ">>> WP_DB_HOST: $WP_DB_HOST"
        echo ">>> WP_DB_NAME: $WP_DB_NAME"
        echo ">>> WP_DB_USER: $WP_DB_USER"
        # ... additional debug commands ...
    fi
    
    sleep $RETRY_INTERVAL
done
```

### 3. Çoklu Doğrulama Aşamaları

WordPress yapılandırması oluşturulduktan sonra bağlantının doğrulanması için ek kontroller eklendi:

```bash
# Enhanced database connection verification after config is created
echo ">>> Verifying database connection through WordPress config..."
MAX_VERIFY_TRIES=10

for i in $(seq 1 $MAX_VERIFY_TRIES); do
    echo ">>> WP DB Check attempt $i/$MAX_VERIFY_TRIES..."
    if wp db check --path=/var/www/html --allow-root; then
        echo ">>> WordPress database connection successful!"
        break
    else
        echo ">>> WordPress database connection failed, retrying in 5 seconds..."
        # ... debug bilgileri ...
        sleep 5
    fi
done
```

### 4. MariaDB Başlatma Scripti İyileştirmeleri

MariaDB tarafında da başlatma scriptine iyileştirmeler yapıldı:

```bash
# Wait until mysqld is fully up and ready
echo ">>> Waiting for MariaDB server to be ready..."
MAX_DB_WAIT=30
for i in $(seq 1 $MAX_DB_WAIT); do
    if mariadb -uroot -e "SELECT 1;" &>/dev/null; then
        echo ">>> MariaDB server is ready after $i seconds"
        break
    fi
    echo ">>> Waiting for MariaDB to initialize... ($i/$MAX_DB_WAIT)"
    sleep 1
    
    # If we've waited too long, restart the process
    if [ $i -eq $MAX_DB_WAIT ]; then
        echo ">>> WARNING: MariaDB initialization timeout! Restarting server..."
        # ... restart logic ...
    fi
done
```

## NGINX Konfigürasyonu

NGINX, projenin web sunucusu bileşenidir ve aşağıdaki özelliklere sahiptir:

1. **SSL/TLS Terminasyonu**: HTTPS bağlantılarını karşılar ve güvenli iletişim sağlar
2. **Reverse Proxy**: WordPress PHP-FPM servisi ile iletişim kurar
3. **HTTPS Zorlaması**: Tüm bağlantılar HTTPS üzerinden yapılır
4. **TLSv1.2/1.3 Desteği**: Modern ve güvenli TLS protokollerini destekler
5. **WordPress URL Rewrite Desteği**: WordPress'in permalinks özelliği için gerekli yapılandırma

### NGINX Yapılandırması

NGINX yapılandırma dosyası (`nginx.conf`):

```nginx
server {
    # Listen on port 443 with SSL
    listen 443 ssl;
    listen [::]:443 ssl;
    
    # Server name (domain)
    server_name merboyac.42.fr www.merboyac.42.fr;
    
    # SSL certificate configuration
    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    
    # Root directory for the WordPress files
    root /var/www/html;
    index index.php index.html index.htm;
    
    # Main location block
    location / {
        try_files $uri $uri/ /index.php?$args;
    }
    
    # PHP handling through PHP-FPM
    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass wordpress:9000;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_param HTTPS on;
    }
    
    # Deny access to hidden files
    location ~ /\.ht {
        deny all;
    }
}
```

### SSL Sertifikaları

Proje, OpenSSL kullanarak kendi kendine imzalanan (self-signed) sertifikalar oluşturur:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=TR/ST=Istanbul/L=Istanbul/O=42School/OU=Inception/CN=merboyac.42.fr"
```

Bu sertifikalar:
- 365 gün geçerli
- 2048-bit RSA anahtar kullanıyor
- merboyac.42.fr domain'i için yapılandırılmış

### Yerel Geliştirme için Domain Ayarları

Projeyi yerel makinenizde test etmek için, `/etc/hosts` dosyasına aşağıdaki satırı eklemeniz gerekmektedir:

```
127.0.0.1 merboyac.42.fr
```

Bu işlemi otomatikleştirmek için sunulan yardımcı scripti kullanabilirsiniz:

```bash
sudo make setup-hosts
```

### NGINX Testi

NGINX yapılandırmasını test etmek için:

```bash
# NGINX yapılandırmasını kontrol et
make test-nginx

# SSL sertifikasını kontrol et
make test-ssl

# HTTPS bağlantısını test et
make curl-test

# NGINX container'ına bağlan
make shell-nginx
```

## Bağlantı Testi

Yapılan değişikliklerin başarılı olduğunu doğrulamak için bir dizi test uygulandı:

### 1. WordPress'ten MariaDB'ye Bağlantı Testi

Doğrudan kullanıcı adı ve şifre ile bağlantı testi:

```bash
docker exec -it wordpress bash -c "apt-get update && apt-get install -y mariadb-client && mysql -h mariadb -u itguy -pitguy5555 -e 'SHOW DATABASES;'"
```

> **Not:** Bu komut, WordPress container'ına mariadb-client'ı yalnızca test amacıyla kurar. Bu yaklaşım sadece hata ayıklama amaçlıdır, production ortamı için değildir. Docker'ın "bir container, bir servis" prensibine göre WordPress container'ında sadece WordPress ve ilgili PHP servisleri çalışmalıdır. Gerçek bir production ortamında bu tür araçları container'a yüklemeniz önerilmez çünkü container boyutunu artırır ve güvenlik risklerine yol açabilir.
>
> **Önemli:** Yukarıdaki komutta şifre direkt olarak yazılmıştır, gerçek senaryolarda şifreleri komut satırında açık olarak vermekten kaçınmalısınız.

**Sonuç:**
```
+-------------------------+
| Database                |
+-------------------------+
| information_schema      |
| wordpress_user_database |
+-------------------------+
```

### 2. WordPress WP-CLI ile Veritabanı Kontrolü (Önerilen Yöntem)

WP-CLI, WordPress'in kendi komut satırı arayüzüdür ve veritabanı bağlantısını test etmek için en güvenli ve en uygun yöntemdir. Harici bir veritabanı istemcisi yüklemeye gerek kalmadan bağlantı kontrolü yapar:

```bash
# Veritabanı bağlantısını kontrol etme
docker exec -it wordpress wp db check --allow-root
```

**Not:** `wp db check` komutu, arka planda `mysqlcheck` aracını kullanır. Bu aracın çalışabilmesi için WordPress container'ına `mariadb-client` paketi yüklemeniz gerekebilir:

```bash
docker exec -it wordpress apt-get update && apt-get install -y mariadb-client
docker exec -it wordpress wp db check --allow-root
```

Alternatif olarak, `mysqlcheck` olmadan veritabanına erişimi doğrulamak için şu komutları kullanabilirsiniz:

```bash
# Veritabanı bağlantısını test etme
docker exec -it wordpress wp db query "SELECT 1;" --allow-root

# WordPress sürümünü kontrol etme (veritabanına erişim gerektirir)
docker exec -it wordpress wp core version --allow-root
```

**Başarılı Sonuç Örneği:**
```
wordpress_user_database.wp_commentmeta             OK
wordpress_user_database.wp_comments                OK
wordpress_user_database.wp_links                   OK
wordpress_user_database.wp_options                 OK
wordpress_user_database.wp_postmeta                OK
wordpress_user_database.wp_posts                   OK
wordpress_user_database.wp_term_relationships      OK
wordpress_user_database.wp_term_taxonomy           OK
wordpress_user_database.wp_termmeta                OK
wordpress_user_database.wp_terms                   OK
wordpress_user_database.wp_usermeta                OK
wordpress_user_database.wp_users                   OK
Success: Database checked.
```

WordPress kurulumunun veritabanı bağlantı ayarlarını görmek için:

```bash
docker exec -it wordpress wp config get DB_HOST --allow-root
docker exec -it wordpress wp config get DB_USER --allow-root
docker exec -it wordpress wp config get DB_NAME --allow-root
```

**Sonuç:**
```
mariadb:3306
itguy
wordpress_user_database
```

### 3. WordPress Yapılandırma Dosyası Kontrolü

```bash
docker exec -it wordpress grep -A 10 DB_ /var/www/html/wp-config.php
```

**Sonuç:**
```php
define( 'DB_NAME', 'wordpress_user_database' );

/** Database username */
define( 'DB_USER', 'itguy' );

/** Database password */
define( 'DB_PASSWORD', 'itguy5555' );

/** Database hostname */
define( 'DB_HOST', 'mariadb:3306' );
```

### 4. MariaDB Kullanıcı İzinleri Kontrolü

```bash
docker exec -it mariadb mysql -u root -e "SELECT User, Host FROM mysql.user WHERE User IN ('itguy', 'merboyacpro'); SHOW GRANTS FOR 'itguy'@'%';"
```

**Sonuç:**
```
+-------------+------+
| User        | Host |
+-------------+------+
| itguy       | %    |
| merboyacpro | %    |
+-------------+------+
+------------------------------------------------------------------------------------------------------+
| Grants for itguy@%                                                                                   |
+------------------------------------------------------------------------------------------------------+
| GRANT USAGE ON *.* TO `itguy`@`%` IDENTIFIED BY PASSWORD '*A6E47F46EFC27AA832B5A5FDD47BAC93FD99F291' |
| GRANT ALL PRIVILEGES ON `wordpress_user_database`.* TO `itguy`@`%`                                   |
+------------------------------------------------------------------------------------------------------+
```

### 5. Container Durumu Kontrolü

```bash
docker ps | grep -E 'mariadb|wordpress'
```

**Sonuç:**
```
5ce88fa84687   wordpress   "wpinit.sh"   3 minutes ago   Up 3 minutes   9000/tcp   wordpress
d3571d7f0540   mariadb     "dbinit.sh"   3 minutes ago   Up 3 minutes   3306/tcp   mariadb
```

### 6. Container'lar Arası Bağlantı Testi Stratejileri

Container'lar arasındaki bağlantıyı test ederken:

- Mümkün olduğunca container'ın sağladığı kendi araçlarını kullanın (örn. WordPress için wp-cli)
- Geçici test container'ları kullanın, üretim container'larını değiştirmeyin
- Hata ayıklama için ayrı bir Dockerfile veya docker-compose.override.yml kullanın
- Test ve debug işlemleri için container'lara gereksiz araçlar yüklemeyin

Örnek olarak, WordPress ve MariaDB arasındaki bağlantıyı test etmek için:

```bash
# 1. WordPress'in kendi wp-cli aracını kullanarak test etme (Bağımlılık gerektirebilir)
docker exec -it wordpress wp db query "SELECT 1;" --allow-root

# 2. WordPress yapılandırmasını kontrol etme
docker exec -it wordpress wp config get DB_USER --allow-root
docker exec -it wordpress wp config get DB_HOST --allow-root

# 3. Geçici bir MariaDB istemci container'ı oluşturarak test etme (En izole yöntem)
docker run --rm --network inception_net mariadb:latest mysql -hmariadb -uitguy -pitguy5555 -e "SHOW DATABASES;"

# 4. Ayrı bir debug container'ı oluşturma
docker run --rm --network inception_net --name db-debug -it mariadb:latest bash
# Sonra container içinden: mysql -hmariadb -uitguy -pitguy5555
```

Bu stratejiler, container'ların izolasyonunu ve sadeliğini korurken, aynı zamanda verimli hata ayıklama sağlar.

Bu stratejiler, container'ların izolasyonunu ve sadeliğini korurken, aynı zamanda verimli hata ayıklama sağlar.

## Best Practices

Docker servislerinin birbirine bağımlı olduğu kompozisyonlarda aşağıdaki best practice'leri uygulamak önerilir:

### 1. "Bir Container, Bir Servis" Prensibi

Docker'ın temel felsefelerinden biri, her container'ın yalnızca bir servisi çalıştırmasıdır:

- Her container tek bir göreve odaklanmalı
- Container'lar arasında net bir ayrım olmalı
- Test ve hata ayıklama dışında container'a ek araçlar/servisler kurulmamalı
- Servisler arası iletişim ağ üzerinden yapılmalı

Bu prensip, sistemin daha modüler, yönetilebilir ve ölçeklenebilir olmasını sağlar.

### 2. Docker Compose'da Healthcheck Kullanımı

```yaml
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
  interval: 5s
  timeout: 3s
  retries: 5
```

ve

```yaml
depends_on:
  mariadb:
    condition: service_healthy
```

### 2. Başlatma Scriptlerinde Sağlam Bağlantı Kontrolü

- TCP bağlantı kontrolü
- Servis yanıt kontrolü 
- Veritabanı sorgu kontrolü
- Kademeli timeout ve yeniden deneme mekanizması
- Detaylı hata ayıklama bilgileri

### 3. Çoklu Doğrulama Stratejisi

- Yapılandırma sonrası doğrulama
- Kurulum öncesi ve sonrası doğrulama
- Otomatik yeniden deneme mekanizmaları

Bu pratikler sayesinde, Docker servislerinin birbirine bağımlılıkları düzgün bir şekilde yönetilir ve servislerin tam olarak hazır olmadan diğer servislerin bağlanmaya çalışmasından kaynaklanan hatalar önlenir.

---

## Sonuç

Bu belge, WordPress ve MariaDB Docker servislerinin bağlantı sorunlarını çözme sürecini detaylandırmaktadır. Uygulanan çözümler, Docker Compose yapılandırmasına bağlı olmadan güvenilir bir bağlantı sağlar ve servislerin doğru sırayla başlatılmasını garanti eder.

Bu yaklaşımlar, herhangi bir Docker kompozisyonunda bağımlı servislerin yönetilmesi için kullanılabilir ve yaygın görülen "veritabanı bağlantı hatası" sorunlarının çözümüne yardımcı olur.

## Güvenlik Notları

Bu belgede test amaçlı olarak bazı komutlarda doğrudan şifreler kullanılmıştır. Gerçek ortamlarda aşağıdaki güvenlik prensiplerini uygulamanız önerilir:

1. **Komut satırında şifreleri açık olarak kullanmaktan kaçının**:
   ```bash
   # YAPMAYIN:
   mysql -uitguy -pitguy5555
   
   # YAPIN:
   mysql -uitguy -p  # Şifre sorulduğunda girin
   ```

2. **Şifre ve hassas bilgileri Docker secrets veya environment dosyalarında saklayın**:
   ```yaml
   secrets:
     db_password:
       file: ../secrets/db_password.txt
   ```

3. **Test komutlarını ve çıktılarını versiyon kontrolüne dahil etmeyin**

4. **Container'lar arası iletişimde güvenli ağ politikaları uygulayın**

5. **Production ortamında test araçlarını ve debug kodlarını temizleyin**

Bu güvenlik önlemleri, projenizin güvenliğini artıracak ve olası veri sızıntılarını önleyecektir.

## Sorun Giderme

### 1. WP-CLI ile Veritabanı Kontrolünde mysqlcheck Hatası

**Sorun:**
```
docker exec -it wordpress wp db check --allow-root
/usr/bin/env: 'mysqlcheck': No such file or directory
```

**Açıklama:**  
WP-CLI'nin `wp db check` komutu, arka planda `mysqlcheck` aracını çağırır. Minimal Docker container'larında bu araç genellikle bulunmaz.

**Çözüm Seçenekleri:**

1. **MariaDB istemcisini yükleme** (Geçici test için):
   ```bash
   docker exec -it wordpress apt-get update && apt-get install -y mariadb-client
   ```

2. **Alternatif WP-CLI komutları kullanma** (mysqlcheck gerektirmez):
   ```bash
   # Doğrudan SQL sorgusu çalıştırma
   docker exec -it wordpress wp db query "SELECT 1;" --allow-root
   
   # Veritabanı tablolarını listeleme
   docker exec -it wordpress wp db tables --allow-root
   ```

3. **Harici bir test container'ı kullanma** (En temiz yaklaşım):
   ```bash
   docker run --rm --network inception_net mariadb:latest mysql -hmariadb -uitguy -pitguy5555 -e "SHOW DATABASES;"
   ```

### 2. WordPress ve MariaDB Arasındaki Bağlantı Zamanlaması Sorunları

**Sorun:** WordPress, MariaDB veritabanı hazır olmadan önce bağlanmaya çalışıyor.

**Çözüm Seçenekleri:**
1. Docker Compose `healthcheck` ve `condition` kullanma
2. Başlatma scriptlerinde sağlam bekleme mekanizmaları ekleme
3. WordPress'i manuel olarak başlatma zamanını kontrol etme
