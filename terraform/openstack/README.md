# Triển khai máy ảo OpenStack bằng Terraform

Thư mục này chứa cấu hình Terraform để tạo một máy ảo cùng mạng riêng, router, Floating IP, security group và volume dữ liệu trên OpenStack. Cấu hình sử dụng các image, flavor và mạng external đã có sẵn; không cài đặt cụm OpenStack.

## Kiến trúc

```text
Mạng external có sẵn: public
        |
        | External gateway
        v
Router: tf-router
        |
        | Router interface
        v
Mạng riêng: tf-private
Subnet: 10.20.0.0/24 — Gateway: 10.20.0.1
        |
        v
Port: tf-vm-01-port + Security group: tf-vm-sg
        |
        v
VM: tf-vm-01 (image cirros, flavor m1.tiny)
        +-- Floating IP cấp từ public, gắn vào port
        +-- Volume dữ liệu: tf-volume-01 (1 GB)
```

Các thành phần OpenStack được cấu hình sử dụng:

- **Neutron:** mạng riêng, subnet, router, port, security group và Floating IP.
- **Nova:** máy ảo và thao tác gắn volume.
- **Glance:** tra cứu image theo tên, chọn image mới nhất nếu có nhiều kết quả phù hợp.
- **Cinder:** tạo volume dữ liệu qua API v3.

## Các file cấu hình

| File | Vai trò |
| --- | --- |
| `versions.tf` | Yêu cầu Terraform `>= 1.9.0`, khai báo provider `terraform-provider-openstack/openstack` phiên bản `3.4.0`. |
| `provider.tf` | Chọn cloud trong `clouds.yaml` và region thông qua biến. |
| `variables.tf` | Khai báo 12 biến đầu vào, kiểu dữ liệu và giá trị mặc định. |
| `terraform.tfvars` | Giá trị cấu hình cho lab; hiện trùng với các giá trị mặc định. |
| `data.tf` | Tra cứu mạng external, image và flavor đã tồn tại. |
| `network.tf` | Tạo mạng riêng IPv4, subnet có DHCP, router và kết nối subnet với router. |
| `security.tf` | Tạo security group và hai rule ingress cho ICMP, SSH. |
| `compute.tf` | Tạo port, VM và Floating IP gắn vào port của VM. |
| `storage.tf` | Tạo Cinder volume và gắn volume vào VM. |
| `outputs.tf` | Xuất ID tài nguyên và địa chỉ IP sau khi triển khai. |
| `.terraform.lock.hcl` | Khóa lựa chọn provider và checksum để hỗ trợ khởi tạo nhất quán. |

Tổng cộng cấu hình khai báo **12 resource** và **3 data source**. VM và Floating IP có `depends_on` để chờ router interface được tạo trước.

## Biến đầu vào

| Biến | Mặc định / giá trị trong `terraform.tfvars` | Ý nghĩa |
| --- | --- | --- |
| `cloud_name` | `kolla-admin` | Tên cloud entry trong `clouds.yaml`. |
| `region` | `RegionOne` | Region OpenStack. |
| `external_network_name` | `public` | Mạng external có sẵn, dùng làm gateway và cấp Floating IP. |
| `image_name` | `cirros` | Image Glance dùng để tạo VM. |
| `flavor_name` | `m1.tiny` | Flavor Nova dùng cho VM. |
| `private_network_name` | `tf-private` | Tên mạng riêng được tạo. |
| `private_subnet_name` | `tf-private-subnet` | Tên subnet được tạo. |
| `private_subnet_cidr` | `10.20.0.0/24` | Dải IPv4 của subnet. |
| `router_name` | `tf-router` | Tên router được tạo. |
| `instance_name` | `tf-vm-01` | Tên VM; port được đặt tên theo mẫu `<instance_name>-port`. |
| `volume_name` | `tf-volume-01` | Tên volume dữ liệu. |
| `volume_size` | `1` | Dung lượng volume theo GB. |

Một số giá trị được ghi trực tiếp trong mã, chưa có biến cấu hình:

- Gateway subnet: `10.20.0.1`. Nếu đổi CIDR, phải sửa gateway trong `network.tf` để nằm trong subnet mới.
- DNS subnet: `8.8.8.8` và `1.1.1.1`; DHCP được bật.
- Tên security group: `tf-vm-sg`.
- Dải nguồn được phép truy cập: `172.20.0.0/24` trong `security.tf`.

## Chính sách truy cập

Security group được gắn trực tiếp vào port của VM và khai báo hai rule **ingress IPv4**:

| Giao thức | Cổng | Dải nguồn được phép | Mục đích |
| --- | --- | --- | --- |
| ICMP | Không áp dụng | `172.20.0.0/24` | Kiểm tra kết nối bằng ping. |
| TCP | `22` | `172.20.0.0/24` | Truy cập SSH. |

Mã hiện tại không khai báo rule egress riêng. Các rule trên chỉ mô tả quyền truy cập ở tầng mạng; kết nối thực tế còn phụ thuộc routing, địa chỉ nguồn mà OpenStack nhìn thấy và dịch vụ trong VM.

## Điều kiện trước khi triển khai

- Có Terraform đáp ứng phiên bản yêu cầu và có thể kết nối các API OpenStack.
- Có cấu hình xác thực `clouds.yaml` mà provider đọc được, với entry tương ứng `cloud_name` (mặc định `kolla-admin`) và region phù hợp.
- Trong project có mạng external `public`, image `cirros` và flavor `m1.tiny`, hoặc thay tên tương ứng trong `terraform.tfvars`.
- Tài khoản có quyền và quota để tạo tài nguyên Nova, Neutron và Cinder, bao gồm Floating IP.
- Mạng external có khả năng định tuyến tới nơi thực hiện kiểm tra kết nối.

Không đặt thông tin xác thực thật vào README. Cấu hình provider trong thư mục chỉ tham chiếu tên cloud và region.

## Triển khai

Chạy từ thư mục gốc repository:

```powershell
cd terraform/openstack
terraform init
terraform validate
terraform plan -out=tfplan
```

Kiểm tra kế hoạch, tên tài nguyên, mạng external và quota trước khi áp dụng:

```powershell
terraform show tfplan
terraform apply tfplan
terraform output
```

Terraform tự đọc `terraform.tfvars` trong thư mục hiện tại. Khi thay đổi cấu hình sau khi tạo `tfplan`, cần chạy lại `terraform plan -out=tfplan` để kế hoạch phản ánh cấu hình mới.

## Kết quả đầu ra và kiểm tra

| Output | Nội dung |
| --- | --- |
| `instance_id` | ID của VM. |
| `instance_name` | Tên VM. |
| `private_ip` | Địa chỉ fixed IP đầu tiên của port VM. |
| `floating_ip` | Floating IP được cấp và gắn vào port. |
| `volume_id` | ID Cinder volume. |
| `private_network_id` | ID mạng riêng. |
| `router_id` | ID router. |

Lấy địa chỉ để kiểm tra từ máy thuộc dải nguồn được cho phép và có đường mạng tới Floating IP:

```powershell
terraform output -raw floating_ip
ping <floating_ip>
ssh <image-user>@<floating_ip>
```

Thay các placeholder bằng giá trị thực. User và phương thức đăng nhập phụ thuộc image; cấu hình hiện tại không tạo key pair, không gán `key_pair` cho VM và không có `user_data` để thiết lập tài khoản.

Volume được gắn vào VM như ổ dữ liệu bổ sung. Terraform chưa phân vùng, tạo filesystem hoặc mount volume trong hệ điều hành khách; cần thực hiện các bước đó trong VM nếu muốn sử dụng ổ.

## Xóa tài nguyên của lab

Lệnh sau lập kế hoạch xóa các tài nguyên đang được quản lý trong Terraform state hiện tại:

```powershell
terraform plan -destroy
terraform destroy
```

Việc xác nhận `destroy` sẽ xóa cả VM và volume dữ liệu do cấu hình tạo. Sao lưu dữ liệu cần giữ trước khi thực hiện. Mạng external, image và flavor được tra cứu bằng data source không phải tài nguyên do cấu hình này tạo.

## Phạm vi hiện tại

Đây là cấu hình lab cho một VM. Chưa có khai báo Kubernetes, cân bằng tải, nhiều VM, boot từ Cinder volume hay cấu hình ứng dụng trong máy ảo. README mô tả mã nguồn hiện tại; việc triển khai thành công và truy cập VM cần được kiểm chứng trên môi trường OpenStack thực tế.
