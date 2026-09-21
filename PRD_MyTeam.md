# PROJECT PRD
## Product Requirements Document

## Tujuan Dokumen
PRD ini digunakan untuk menjelaskan apa yang akan dibangun, untuk siapa, mengapa produk dibutuhkan, dan kebutuhan utama aplikasi MyTeam tanpa menjelaskan detail implementasi kode.

---

## 1. Problem & Users

### 1.1 Problem Statement
Mahasiswa Universitas Andalas yang ingin mengikuti kegiatan yang membutuhkan pembentukan tim masih kesulitan menemukan tim atau anggota yang sesuai dengan minat, keahlian, dan pengalaman. Informasi mengenai mahasiswa yang mencari tim maupun mahasiswa yang membutuhkan anggota masih tersebar di berbagai grup dan media komunikasi, sehingga proses pencarian dan pembentukan tim menjadi kurang efektif. Kondisi ini dapat menyebabkan mahasiswa kehilangan kesempatan untuk berpartisipasi dalam kegiatan yang sesuai dengan minat, keahlian, dan pengalamannya.

### 1.2 Target Users
Pengguna utama MyTeam adalah mahasiswa aktif Universitas Andalas yang ingin mengikuti kegiatan yang membutuhkan pembentukan tim, seperti lomba, penelitian, proyek, atau kegiatan lainnya. Pengguna memiliki dua peran, yaitu pencari tim yang ingin menemukan dan bergabung dengan tim sesuai dengan minat, keahlian, dan pengalamannya, serta pencari anggota yang telah memiliki ide, kesempatan, atau tim dan membutuhkan anggota dengan keahlian tertentu. Satu mahasiswa dapat memiliki kedua peran tersebut sesuai dengan kegiatan yang diikuti.

### 1.3 User Needs / Pain Points
- Mahasiswa membutuhkan cara yang lebih mudah untuk menemukan tim atau calon anggota yang sesuai dengan minat, keahlian, pengalaman, dan kebutuhan suatu kegiatan.
- Mahasiswa membutuhkan jangkauan pencarian yang lebih luas untuk menemukan tim atau calon anggota di luar lingkungan pertemanan, kelas, dan organisasi.
- Mahasiswa membutuhkan informasi profil, minat, keahlian, pengalaman, dan portofolio untuk menilai kesesuaian dengan tim atau calon anggota.
- Mahasiswa membutuhkan proses yang jelas untuk membuat tim, mencari tim atau calon anggota, mengajukan diri untuk bergabung, serta menerima atau menolak pengajuan.
- Mahasiswa membutuhkan informasi mengenai status pengajuan agar dapat mengetahui apakah pengajuan bergabung masih menunggu, diterima, atau ditolak.

### 1.4 Project Goal
MyTeam bertujuan menyediakan aplikasi mobile bagi mahasiswa Universitas Andalas untuk menemukan, membentuk, dan bergabung dengan tim berdasarkan minat, keahlian, pengalaman, dan kebutuhan kegiatan. Aplikasi ini diharapkan dapat mempermudah dan mempercepat proses pencarian serta pembentukan tim, sehingga mahasiswa dapat menemukan rekan yang sesuai dan berpartisipasi dalam berbagai kegiatan yang membutuhkan pembentukan tim.

---

## 2. Product Requirements

### 2.1 Functional Requirements
- **FR-01:** Pengguna dapat mendaftarkan akun.
- **FR-02:** Pengguna dapat masuk ke aplikasi menggunakan akun terdaftar.
- **FR-03:** Pengguna dapat melengkapi data profil dengan mengunggah foto profil (fitur perangkat: kamera/file upload) serta mengisi nama, program studi, fakultas, minat, keahlian, pengalaman, portofolio, kontak, dan tautan media sosial.
- **FR-04:** Pengguna dapat mengubah data profil.
- **FR-05:** Pengguna dapat menghapus data profil.
- **FR-06:** Pengguna dapat melihat profil pengguna lain.
- **FR-07:** Sistem dapat mengirimkan notifikasi kepada pengguna setelah data profil berhasil diperbarui.
- **FR-08:** Pengguna (Pencari anggota) dapat membuat tim dengan mengisi data tim berupa nama tim, nama kegiatan, kategori kegiatan, deskripsi, jumlah anggota yang dibutuhkan, posisi anggota yang dibutuhkan, keahlian yang dibutuhkan, serta data anggota yang telah bergabung.
- **FR-09:** Pengguna (Pencari anggota) dapat mengubah data tim.
- **FR-10:** Pengguna dapat melihat detail data tim.
- **FR-11:** Pengguna (Pencari anggota) dapat menghapus tim yang dibuat.
- **FR-12:** Sistem dapat mengirimkan notifikasi kepada pengguna (Pencari anggota) ketika terdapat pengajuan bergabung ke tim yang dibuatnya.
- **FR-13:** Pengguna dapat mencari tim berdasarkan kata kunci.
- **FR-14:** Pengguna dapat mencari calon anggota berdasarkan kata kunci.
- **FR-15:** Pengguna dapat memfilter hasil pencarian berdasarkan kategori kegiatan, posisi, dan keahlian.
- **FR-16:** Pengguna dapat menyimpan kriteria pencarian yang digunakan untuk memantau tim atau calon anggota yang sesuai.
- **FR-17:** Sistem dapat mengirimkan notifikasi kepada pengguna ketika terdapat tim atau calon anggota baru yang sesuai dengan kriteria pencarian yang disimpan.
- **FR-18:** Pengguna (Pencari tim) dapat mengajukan permintaan untuk bergabung ke tim.
- **FR-19:** Pengguna (Pencari anggota) dapat melihat daftar pengajuan bergabung ke timnya.
- **FR-20:** Pengguna (Pencari anggota) dapat menerima atau menolak pengajuan bergabung.
- **FR-21:** Pengguna (Pencari tim) dapat melihat status pengajuan bergabung.
- **FR-22:** Sistem dapat mengirimkan notifikasi kepada pengguna ketika terdapat pengajuan bergabung atau perubahan status pengajuan.

### 2.2 Non-functional Requirements
- **NFR-01:** Halaman utama harus dapat ditampilkan dalam waktu ≤ 3 detik pada kondisi jaringan normal.
- **NFR-02:** Hasil pencarian harus dapat ditampilkan dalam waktu ≤ 3 detik setelah pengguna memasukkan kata kunci atau menerapkan filter pada kondisi jaringan normal.
- **NFR-03:** Antarmuka aplikasi harus mudah digunakan oleh mahasiswa Universitas Andalas tanpa memerlukan pelatihan khusus.
- **NFR-04:** Aplikasi harus dapat berjalan pada perangkat dengan sistem operasi Android versi minimal 8.0.
- **NFR-05:** Data pengguna harus dapat diakses dan ditampilkan sesuai dengan hak akses yang ditentukan oleh sistem.
- **NFR-06:** Data aplikasi harus disimpan menggunakan database yang mendukung pertukaran data antarpengguna dan tidak menggunakan Firebase Storage.
- **NFR-07:** Sistem harus menjaga konsistensi data pengguna, tim, anggota tim, pengajuan bergabung, dan kriteria pencarian ketika terjadi perubahan data.
- **NFR-08:** Sistem harus dapat mengirimkan notifikasi setelah aktivitas yang memicu notifikasi berhasil diproses pada kondisi jaringan normal.
- **NFR-09:** Setiap modul harus terintegrasi dengan modul lainnya dan dapat digunakan melalui alur utama aplikasi.

### 2.3 Core Features

| No. | Core Feature | Purpose / Value |
|---|---|---|
| 1 | Akun & Profil | Memungkinkan mahasiswa membuat akun dan menampilkan informasi diri, minat, keahlian, pengalaman, serta portofolio sebagai dasar untuk menilai kesesuaian dalam pembentukan tim. |
| 2 | Pembentukan Tim | Memungkinkan mahasiswa membuat tim dan menentukan informasi serta kebutuhan anggota untuk suatu kegiatan. |
| 3 | Pencarian Tim & Anggota | Memudahkan mahasiswa menemukan tim atau calon anggota berdasarkan kata kunci dan kriteria, serta menyimpan kriteria pencarian untuk memperoleh informasi mengenai tim atau calon anggota baru yang sesuai. |
| 4 | Pengajuan Bergabung | Memfasilitasi proses pengajuan mahasiswa untuk bergabung ke tim serta proses penerimaan atau penolakan pengajuan oleh pencari anggota. |
| 5 | Notifikasi | Memberikan informasi kepada pengguna mengenai tim atau calon anggota baru yang sesuai dengan kriteria pencarian, pengajuan bergabung, serta perubahan status pengajuan. |

### 2.4 User Flow
Terdapat dua alur utama pengguna dalam aplikasi MyTeam, yaitu pencari anggota dan pencari tim, sebagai berikut:

1. **Pencari Anggota:** Open App → Daftar/Login → Beranda → Buat Tim Baru → Tim Dibuat → Melihat Pengajuan Bergabung → Melihat Detail Pengajuan → Menerima Pengajuan → Pembentukan Tim Selesai.
2. **Pencari Tim:** Open App → Daftar/Login → Beranda → Mencari Tim → Memfilter Hasil → Menyimpan Kriteria Pencarian → Melihat Detail Tim → Mengajukan Bergabung → Melihat Status Pengajuan → Bergabung ke Tim → Pembentukan Tim Selesai.

### 2.5 Data Requirements

| Data / Entity | Key Information | Purpose |
|---|---|---|
| **Pengguna** | ID_pengguna, NIM, kata_sandi, nama, program_studi, fakultas, foto_profil, minat, keahlian, pengalaman, portofolio, kontak, tautan_media_sosial, kriteria_pencarian | Menyimpan data akun dan profil mahasiswa yang digunakan untuk masuk ke aplikasi, pencarian, serta pembentukan tim, termasuk kriteria pencarian yang disimpan pengguna. |
| **Tim** | ID_tim, nama_tim, nama_kegiatan, kategori_kegiatan, deskripsi, jumlah_anggota_dibutuhkan, posisi_anggota_dibutuhkan, keahlian_yang_dibutuhkan, pembuat_tim | Menyimpan informasi tim dan kebutuhan anggota untuk suatu kegiatan. |
| **Anggota_Tim** | ID_anggota_tim, ID_tim, ID_pengguna, posisi | Menyimpan data mahasiswa yang telah diterima dan bergabung dalam suatu tim. |
| **Pengajuan_Bergabung** | ID_pengajuan, ID_tim, ID_pengguna, tanggal_pengajuan, status_pengajuan | Menyimpan pengajuan mahasiswa untuk bergabung ke tim serta status pengajuannya, yaitu menunggu, diterima, atau ditolak. |

### 2.6 Constraints & Assumptions

**Constraints**
- Aplikasi dikembangkan menggunakan Flutter untuk perangkat dengan sistem operasi Android versi minimal 8.0.
- Aplikasi membutuhkan koneksi internet untuk menjalankan fungsi yang memerlukan pertukaran dan pembaruan data antarpengguna.
- Data aplikasi disimpan menggunakan database yang mendukung pertukaran data antarpengguna dan tidak menggunakan Firebase Storage.
- Aplikasi tidak menggunakan admin sebagai aktor utama sehingga proses utama dilakukan secara langsung antarmahasiswa.
- Pengunggahan foto profil memerlukan izin akses terhadap kamera atau galeri perangkat.

**Assumptions**
- Pengguna aplikasi merupakan mahasiswa aktif Universitas Andalas.
- Pengguna memiliki perangkat Android dengan versi yang memenuhi persyaratan minimum aplikasi.
- Pengguna memiliki koneksi internet yang memadai ketika menggunakan fungsi yang membutuhkan pertukaran data.
- Pengguna memberikan data profil, informasi tim, dan pengajuan bergabung yang benar dan sesuai dengan kondisi sebenarnya.
- Satu mahasiswa dapat berperan sebagai pencari tim, pencari anggota, atau keduanya sesuai dengan kebutuhan kegiatan yang diikuti.
- Informasi profil, tim, dan kebutuhan anggota yang ditampilkan dalam aplikasi berasal dari data yang dimasukkan oleh pengguna.

### 2.7 Success Criteria
- Pengguna dapat menemukan tim atau calon anggota yang sesuai berdasarkan minat, keahlian, pengalaman, dan kebutuhan kegiatan.
- Pengguna dapat menemukan tim atau calon anggota melalui aplikasi tanpa harus bergantung pada berbagai grup atau media komunikasi.
- Pengguna dapat melihat informasi profil dan tim untuk menilai kesesuaian sebelum bergabung atau menerima anggota.
- Pengguna dapat membuat tim, mengajukan permintaan bergabung, serta menerima atau menolak pengajuan melalui aplikasi.
- Pengguna dapat mengetahui status pengajuan bergabung dan menerima notifikasi terkait pengajuan atau perubahan statusnya.
- Pengguna dapat menemukan dan membentuk tim sesuai dengan kebutuhan kegiatan yang diikuti.

---

## 3. Scope

### 3.1 In Scope
- Pengelolaan akun dan profil mahasiswa, termasuk pendaftaran, login, data profil, portofolio, kontak, tautan media sosial, dan foto profil.
- Pembentukan tim, termasuk pembuatan, pengubahan, penghapusan, dan penampilan informasi serta kebutuhan anggota tim.
- Pencarian tim dan calon anggota berdasarkan kata kunci dan kriteria yang tersedia, termasuk penyimpanan kriteria pencarian.
- Pengajuan bergabung, termasuk pengajuan permintaan bergabung, melihat status pengajuan, serta menerima atau menolak pengajuan oleh pembuat tim.
- Notifikasi terkait pembaruan profil, tim atau calon anggota yang sesuai dengan kriteria pencarian, pengajuan bergabung, dan perubahan status pengajuan.

### 3.2 Out of Scope
- Penyediaan daftar atau katalog kegiatan, seperti lomba, penelitian, proyek, atau kegiatan lainnya.
- Pendaftaran resmi ke suatu kegiatan melalui aplikasi.
- Pengelolaan tim setelah proses pembentukan tim selesai, seperti pembagian tugas, jadwal, dan progres kegiatan.
- Fitur chat atau komunikasi langsung antarmahasiswa di dalam aplikasi.
- Sistem pembayaran atau transaksi dalam aplikasi.
- Sistem rekomendasi tim atau anggota menggunakan AI atau machine learning.
- Pengelolaan aplikasi oleh admin sebagai aktor utama.
- Penggunaan Firebase Storage untuk menyimpan data atau file aplikasi.
