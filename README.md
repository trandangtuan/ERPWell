# Giới thiệu
WMS là phần mềm quản lý bán hàng, kinh doanh sử dụng tại các điểm cửa hàng nhỏ, các đơn vị kinh doanh hộ gia đình, siêu thị hoặc trung tâm thương mại.

Ưu điểm của Part Việt so với các phần mềm bán hàng truyền thống
- Phần mềm chạy trên nền web, lưu trữ đám mây, không cần phải cài đặt, chỉ cần khởi tạo và sử dụng
- Phần mềm được hỗ lưu trữ bản sao, cho phép khôi phục lại dữ liệu khi có lỗi xảy ra.
- Cho phép người dùng sử dụng trên các thiết bị máy tính bảng, điện thoại từ xa để quản lý tình hình kinh doanh một cách dễ dàng. 

Ưu điểm của Part Việt so với các phần mềm bán hàng nền web khác
- Sử dụng học máy AI, deep learning để phân tích dữ liệu người dùng, đưa ra thói quen gợi ý trong quá trình bán hàng hoặc tiếp thị lại.
- Cho phép khách hàng có thể đặt hàng trước qua mạng.    
- Được tư vấn và hỗ trợ tận nơi, bổ sung các chức năng cần thiết cho từng mục đích của mỗi cửa hàng. Phù hợp với cá nhân, hộ gia đình kinh doanh nhỏ lẻ.  
- Miễn phí & Mã nguồn mở

# Tiến độ dự án
- Hoàn thành cơ bản phần quản lý cho chủ cửa hàng
- Đang hoàn thiện chức năng bán hàng

# Chức năng đã hoạt động
- Quản lý sản phẩm
- Quản lý đối tác: Khách hàng & Nhà cung cấp
- Quản lý nhập hàng
- Quảng lý đặt hàng trước khi nhập từ nhà cung cấp
- Quản lý bán hàng: Payment và lập hóa đơn mua hàng
- Quản lý người dùng trong cửa hàng

![QuanLy](screenshots/quanly.png)
![BanHang](screenshots/banhang.png)

# Chức năng cần bổ sung
- In hóa đơn & Tùy chỉnh mẫu hóa đơn
- Cho phép làm việc Offline ngay cả khi mất mạng. Đồng bộ dữ liệu khi có mạng trở lại
- Cho phép lưu phiên làm việc và phục hồi khi có sự cố mất điện
- Cho phép Payment nhiều hóa đơn
- Cho phép in lại hóa đơn đã Payment
- Sao lưu dữ liệu hàng ngày. Tối đa lên đến 7 ngày. Nhằm ngăn chặn mất mát dữ liệu.
- Cho phép Payment trên máy tính bảng
- Cho phép quản lý trên điện thoại, máy tính bảng
- Cho phép đồng bộ dữ liệu từ trên trang TMĐT khác: Tiki, Shopee, Lazada, Sendo
- Tạo trang web bán hàng
- Kết nối với Facebook Fanpage để quản lý và thực thi QC, chiến dịch Marketing...
- Bán hàng trên facebook, sàn TMĐT, website khác
- Hỗ trợ nhiều chi nhánh
- Chức năng quản lý nhân sự - lương nhân viên
- Chức năng quản lý quan hệ khách hàng (CRM)
- Quản lý kho
- Quản lý hàng hóa
- Quản lý sản xuất
- Quản lý thuế
- Quản lý tài sản cố định
- Quản lý tài chính - kế toán
- Báo cáo quản trị
- Quản lý và bán hàng đa kênh
- Quản lý khuyến mại
- Quản lý nhà cung cấp	
- Quản lý chuỗi cửa hàng	
- Quản lý giao hàng	
- Tích hợp đối tác vận chuyển
- Quản lý công nợ
- Chăm sóc khách hàng

# Tìm bạn hợp tác & kinh doanh
Một mình làm thì không xuể vậy nên các bạn có thể cùng tham gia phát triển dự án với mình nhé,

Phần mềm đương nhiên vẫn là miễn phí nhé mọi người. Ngoài ra, mình muốn hợp tác để làm bản thương mại mà người dùng không cần phải cài đặt server mà sử dụng được ngay. Mình là dân lập trình nên không có kinh nghiệm trong việc kinh doanh nên bạn nào có kinh nghiệm có thể hợp tác với mình nhé. Vì kinh doanh thì phải có bộ phận bán hàng, marketing và thiết bị còn mình thì chỉ biết code thôi :)) 

# Hướng dẫn sử dụng
## Phân tích nhanh dự án
- WMS là ứng dụng Ruby on Rails 5.2, Ruby 2.5.1, dùng MySQL làm CSDL chính.
- Giao diện có Rails views truyền thống và phần frontend Vue 2/Webpacker trong `app/javascript`.
- Dự án đã có i18n với locale mặc định là tiếng Việt tại `config/application.rb`.
- Các bản dịch nằm trong `config/locales`, hiện có `vi.yml`, `en.yml`, `devise.vi.yml`, `devise.en.yml`.
- Dự án có Redis cho Action Cable/cache jobs và Elasticsearch 6.x thông qua Chewy.

## Chạy bằng Docker
Yêu cầu: Docker và Docker Compose.

### Bước 1: Build image
```bash
docker compose build
```

### Bước 2: Tạo database và seed dữ liệu
```bash
docker compose run --rm web bundle exec rails db:create db:migrate db:seed
```

### Bước 3: Import dữ liệu tỉnh/huyện/xã
```bash
docker compose exec -T db mysql -uroot -proot --default-character-set=utf8 ParkViet_development < db/diadanh_2018-05-05.sql
```

Nếu container `db` chưa chạy, bật trước bằng:
```bash
docker compose up -d db
```

### Bước 4: Chạy ứng dụng
```bash
docker compose up
```

Mở trình duyệt tại:
```text
http://localhost:3000
```

Webpack dev server chạy tại cổng `3035`. Các service đi kèm:
- MySQL: `localhost:3306`, user `root`, password `root`
- Redis: `localhost:6379`
- Elasticsearch: `localhost:9200`

### Lệnh thường dùng
```bash
docker compose run --rm web bundle exec rails c
docker compose run --rm web bundle exec rails db:migrate
docker compose run --rm web bundle exec rails db:seed
docker compose down
```

Muốn xóa toàn bộ dữ liệu Docker volume để chạy lại từ đầu:
```bash
docker compose down -v
```

## Hướng dẫn thêm bản dịch
Dự án dùng Rails I18n. Locale mặc định đang là `:vi` trong `config/application.rb`:

```ruby
config.i18n.default_locale = :vi
```

### Thêm hoặc sửa câu chữ tiếng Việt
Sửa file:
```text
config/locales/vi.yml
```

Ví dụ thêm key mới:
```yaml
vi:
  products:
    index:
      export_product: Xuất danh sách hàng hóa
```

Trong view/controller gọi:
```erb
<%= t("products.index.export_product") %>
```

### Thêm ngôn ngữ mới
Tạo file locale mới, ví dụ tiếng Nhật:
```text
config/locales/ja.yml
```

Nội dung mẫu:
```yaml
ja:
  products:
    index:
      add_product: 商品を追加
```

Nếu muốn đổi locale mặc định, sửa `config/application.rb`:
```ruby
config.i18n.default_locale = :ja
```

### Dịch Devise
Các câu đăng nhập/đăng ký/quên mật khẩu của Devise nằm riêng tại:
```text
config/locales/devise.vi.yml
config/locales/devise.en.yml
```

Khi thêm ngôn ngữ mới, nên tạo thêm file tương ứng, ví dụ:
```text
config/locales/devise.ja.yml
```

### Lưu ý
- YAML rất nhạy với thụt lề, nên dùng 2 dấu cách cho mỗi cấp.
- Key trong các file locale phải nằm dưới mã ngôn ngữ tương ứng như `vi:`, `en:`, `ja:`.
- Sau khi sửa file dịch, restart Rails server để chắc chắn app nhận bản dịch mới.

## Cài đặt
### Bước 1: Cài đặt database
 - rails db:migrate RAILS_ENV=production
 - rails db:seed
 - rake assets:precompile, rake assets:clobber
 
### Bước 2: Import CSDL tỉnh/huyện/xã
 - CSDL tại db/diadanh_2018-05-05.sql
 mysql -uroot -proot --default-character-set=utf8 parkviet < ...
### Bước 3: Cài đặt Redis & Elastic search

### Bước 4: Run server
- Run rails server: Rails s
- Run front-end server: ruby ./bin/webpack-dev-server
 
## Đăng nhập và sử dụng

# Mua cho mình cốc cà phê
Mình phát triển ứng dụng miễn phí cho tất cả mọi người sử dụng, nếu mọi người thấy ứng dụng giúp ích và có giá trị thì đừng quên mua cho mình cốc cà phê nhé. Cảm ơn các bạn.

TK Vietcombank: 0611001909717, Bùi Thế Hiển, chi nhánh Ba Đình.
