# PRD MyTeam — Aplikasi Mobile Pencarian dan Pembentukan Tim Mahasiswa Unand

> Product Requirements Document

| Item | Keterangan |
| --- | --- |
| **Project Name** | MyTeam – Aplikasi Mobile Pencarian dan Pembentukan Tim Mahasiswa Unand |
| **Team** | Nayla Puspita Sari (2411521007), Diva Ramadhani (2411521017), Fuadi Dhiyaulhaq (2411522001), Rafa Gian Atthari (2411522014) |
| **Course** | Mobile Programming |
| **Version** | 1.2 |
| **Date** | 30 September 2026 |

**Tujuan dokumen:** PRD ini digunakan untuk menjelaskan apa yang akan dibangun, untuk siapa, mengapa produk dibutuhkan, dan kebutuhan utama aplikasi MyTeam tanpa menjelaskan detail implementasi kode.

---

## 1. Problem & Users

### 1.1 Problem Statement

Mahasiswa Universitas Andalas yang ingin mengikuti kegiatan yang membutuhkan pembentukan tim masih kesulitan menemukan tim atau anggota yang sesuai dengan minat, keahlian, dan pengalaman. Informasi mengenai mahasiswa yang mencari tim maupun mahasiswa yang membutuhkan anggota masih tersebar di berbagai grup dan media komunikasi, sehingga proses pencarian dan pembentukan tim menjadi kurang efektif. Kondisi ini dapat menyebabkan mahasiswa kehilangan kesempatan untuk berpartisipasi dalam kegiatan yang sesuai dengan minat, keahlian, dan pengalamannya.

### 1.2 Target Users

Pengguna utama MyTeam adalah mahasiswa aktif Universitas Andalas yang ingin mengikuti kegiatan yang membutuhkan pembentukan tim, seperti lomba, penelitian, proyek, atau kegiatan lainnya.

Pengguna memiliki dua peran:

- **Pencari tim** — ingin menemukan dan bergabung dengan tim sesuai dengan minat, keahlian, dan pengalamannya.
- **Pencari anggota (pembuat tim)** — telah memiliki ide, kesempatan, atau tim dan membutuhkan anggota dengan keahlian tertentu.

Satu mahasiswa dapat memiliki kedua peran tersebut sesuai dengan kegiatan yang diikuti, dan dapat mengatur preferensi pencariannya sebagai pencari tim, pencari anggota, atau keduanya.

### 1.3 User Needs / Pain Points

- Mahasiswa membutuhkan cara yang lebih mudah untuk menemukan tim atau calon anggota yang sesuai dengan minat, keahlian, pengalaman, dan kebutuhan suatu kegiatan.
- Mahasiswa membutuhkan jangkauan pencarian yang lebih luas untuk menemukan tim atau calon anggota di luar lingkungan pertemanan, kelas, dan organisasi.
- Mahasiswa membutuhkan informasi profil, pendidikan, minat, keahlian, dan pengalaman beserta bukti pendukungnya untuk menilai kesesuaian dengan tim atau calon anggota.
- Mahasiswa membutuhkan proses yang jelas untuk membuat tim, mencari tim atau calon anggota, mengajukan diri untuk bergabung, mengajukan permintaan kepada calon anggota, serta menerima atau menolak pengajuan.
- Mahasiswa membutuhkan informasi mengenai status pengajuan agar dapat mengetahui apakah pengajuan bergabung masih menunggu, diterima, atau ditolak.

### 1.4 Project Goal

MyTeam bertujuan menyediakan aplikasi mobile bagi mahasiswa Universitas Andalas untuk menemukan, membentuk, dan bergabung dengan tim berdasarkan minat, keahlian, pengalaman, dan kebutuhan kegiatan. Aplikasi ini diharapkan dapat mempermudah dan mempercepat proses pencarian serta pembentukan tim, sehingga mahasiswa dapat menemukan rekan yang sesuai dan berpartisipasi dalam berbagai kegiatan yang membutuhkan pembentukan tim.

---

## 2. Product Requirements

### 2.1 Functional Requirements

#### Akun & Data Riwayat Diri

- **FR-01:** Pengguna dapat mengelola informasi pendidikan yang terdiri dari program studi, fakultas, tahun masuk, dan IPK, termasuk menambahkan, mengubah, dan menghapus data.
- **FR-02:** Pengguna dapat mengelola informasi diri berupa deskripsi singkat, keahlian, dan minat, termasuk menambahkan, mengubah, dan menghapus data.
- **FR-03:** Pengguna dapat mengelola informasi pengalaman yang terdiri dari nama kegiatan, peran, tahun, deskripsi, dan bukti pendukung berupa foto atau dokumen yang dapat diunggah melalui perangkat (native).
- **FR-04:** Pengguna dapat melihat informasi tim yang diikuti, yang terdiri dari nama tim, kegiatan, kategori, dan peran pengguna dalam tim.
- **FR-05:** Pengguna dapat mengelola preferensi pencarian yang menunjukkan apakah pengguna sedang mencari tim, mencari anggota, atau keduanya.
- **FR-06:** Sistem dapat mengirimkan notifikasi kepada pengguna setelah informasi riwayat diri berhasil ditambahkan, diubah, atau dihapus.

#### Pembentukan Tim

- **FR-07:** Pengguna dapat membuat tim baru dengan mengisi informasi tim dan mengunggah dokumen pendukung seperti poster atau panduan kegiatan (native).
- **FR-08:** Pengguna dapat melihat daftar dan detail tim yang telah dibuatnya.
- **FR-09:** Pengguna dapat mengubah informasi dan dokumen pendukung pada tim yang telah dibuat, kecuali kategori kegiatan (native).
- **FR-10:** Pengguna dapat menghapus tim yang telah dibuat.
- **FR-11:** Pengguna menerima notifikasi ketika terdapat pengajuan bergabung ke tim yang dibuatnya.

#### Pencarian Tim & Pengajuan Bergabung

- **FR-12:** Pengguna sebagai pencari tim dapat melihat feed tim atau kegiatan terbaru yang tersedia.
- **FR-13:** Pengguna sebagai pencari tim dapat melakukan pencarian dan penyaringan tim berdasarkan nama kegiatan, kategori kegiatan, keahlian yang dibutuhkan, dan kriteria lainnya.
- **FR-14:** Pengguna sebagai pencari tim dapat melihat detail tim dari hasil pencarian.
- **FR-15:** Pengguna sebagai pencari tim dapat mengajukan permintaan untuk bergabung ke tim yang dipilih.
- **FR-16:** Pembuat tim dapat melihat daftar pengajuan bergabung ke tim yang dibuatnya.
- **FR-17:** Pembuat tim dapat melihat detail pengajuan bergabung.
- **FR-18:** Pembuat tim dapat menerima atau menolak pengajuan bergabung.
- **FR-19:** Pengguna dapat melihat status pengajuan bergabung dan menerima notifikasi ketika status pengajuan berubah.

#### Pencarian Anggota & Pengajuan Anggota

- **FR-20:** Pengguna sebagai pencari anggota dapat mencari calon anggota berdasarkan nama pengguna, keahlian, pengalaman, dan minat yang tersedia pada profil.
- **FR-21:** Pengguna sebagai pencari anggota dapat melihat detail profil calon anggota dari hasil pencarian.
- **FR-22:** Pembuat tim dapat mengajukan permintaan kepada calon anggota untuk bergabung ke tim yang dibuatnya.
- **FR-23:** Calon anggota dapat melihat detail tim dan menerima atau menolak pengajuan untuk bergabung ke tim.
- **FR-24:** Pengguna sebagai pembuat tim menerima notifikasi ketika terdapat pengajuan bergabung dari calon anggota atau ketika undangan bergabung yang dikirimkan kepada calon anggota diterima atau ditolak.

### 2.2 Non-functional Requirements

- **NFR-01:** Halaman utama harus dapat ditampilkan dalam waktu ≤ 3 detik pada kondisi jaringan normal.
- **NFR-02:** Hasil pencarian harus dapat ditampilkan dalam waktu ≤ 3 detik setelah pengguna memasukkan kata kunci atau menerapkan filter pada kondisi jaringan normal.
- **NFR-03:** Antarmuka aplikasi harus mudah digunakan oleh mahasiswa Universitas Andalas tanpa memerlukan pelatihan khusus.
- **NFR-04:** Aplikasi harus dapat berjalan pada perangkat dengan sistem operasi Android versi minimal 8.0.
- **NFR-05:** Data pengguna harus dapat diakses dan ditampilkan sesuai dengan hak akses yang ditentukan oleh sistem.
- **NFR-06:** Data aplikasi harus disimpan menggunakan database yang mendukung pertukaran data antarpengguna dan tidak menggunakan Firebase Storage.
- **NFR-07:** Sistem harus menjaga konsistensi data pengguna, data diri, tim, kebutuhan tim, dokumen pendukung, anggota tim, pengajuan bergabung tim, pengajuan anggota, dan notifikasi ketika terjadi perubahan data, termasuk ketika tim dihapus.
- **NFR-08:** Sistem harus dapat mengirimkan notifikasi setelah aktivitas yang memicu notifikasi berhasil diproses pada kondisi jaringan normal.
- **NFR-09:** Setiap modul harus terintegrasi dengan modul lainnya dan dapat digunakan melalui alur utama aplikasi.

### 2.3 Core Features

| No. | Core Feature | Purpose / Value |
| --- | --- | --- |
| 1 | Akun & Data Riwayat Diri | Memungkinkan mahasiswa membuat akun dan mengelola informasi diri, pendidikan, keahlian, minat, pengalaman beserta bukti pendukung, serta preferensi pencarian, dan melihat tim yang diikuti sebagai dasar untuk menilai kesesuaian dalam pembentukan tim. |
| 2 | Pembentukan Tim | Memungkinkan mahasiswa membuat, melihat, mengubah, dan menghapus tim beserta kebutuhan anggota dan dokumen pendukung (poster atau panduan kegiatan) untuk suatu kegiatan. |
| 3 | Pencarian Tim & Pengajuan Bergabung | Memudahkan pencari tim melihat feed tim terbaru, mencari dan menyaring tim, melihat detail tim, serta mengajukan permintaan bergabung; pembuat tim dapat melihat serta menerima atau menolak pengajuan, dan pencari tim dapat memantau status pengajuannya. |
| 4 | Pencarian Anggota & Pengajuan Anggota | Memudahkan pembuat tim mencari calon anggota berdasarkan nama, keahlian, pengalaman, dan minat, melihat profil calon anggota, serta mengajukan permintaan bergabung yang dapat diterima atau ditolak oleh calon anggota. |
| 5 | Notifikasi | Memberikan informasi kepada pengguna mengenai pembaruan data riwayat diri, pengajuan bergabung ke tim, pengajuan kepada calon anggota beserta responsnya, dan perubahan status pengajuan. |

### 2.4 User Flow

Terdapat dua peran utama pengguna dalam aplikasi MyTeam, yaitu pencari anggota dan pencari tim. Masing-masing peran memiliki dua jalur alur:

1. **Pencari Anggota (menerima pengajuan):**
   Open App → Daftar/Login → Beranda → Buat Tim Baru → Tim Dibuat → Melihat Daftar Pengajuan Bergabung → Melihat Detail Pengajuan → Menerima Pengajuan → Pembentukan Tim Selesai.

2. **Pencari Anggota (mengajukan ke calon anggota):**
   Open App → Daftar/Login → Beranda → Mencari Calon Anggota → Melihat Profil Calon Anggota → Mengajukan Permintaan Bergabung kepada Calon Anggota → Menerima Notifikasi Respons Calon Anggota → Pembentukan Tim Selesai.

3. **Pencari Tim (mengajukan ke tim):**
   Open App → Daftar/Login → Beranda (Feed Tim) → Mencari dan Memfilter Tim → Melihat Detail Tim → Mengajukan Bergabung → Melihat Status Pengajuan → Bergabung ke Tim → Pembentukan Tim Selesai.

4. **Pencari Tim (menerima pengajuan dari pembuat tim):**
   Open App → Daftar/Login → Beranda → Menerima Notifikasi Pengajuan → Melihat Detail Tim → Menerima atau Menolak Pengajuan → Bergabung ke Tim → Pembentukan Tim Selesai.

### 2.5 Data Requirements

Data utama yang digunakan dan disimpan dalam aplikasi MyTeam, sesuai dengan ERD:

| Data / Entity | Key Information | Purpose |
| --- | --- | --- |
| **Pengguna** | id_pengguna, nim, kata_sandi, nama_pengguna, foto_profil | Menyimpan data akun mahasiswa yang digunakan untuk masuk ke aplikasi dan sebagai induk dari seluruh data profil, tim, pengajuan, dan notifikasi. |
| **Data_Diri** | id_pengguna, deskripsi_singkat, kontak, program_studi, fakultas, ipk | Menyimpan informasi diri dan pendidikan mahasiswa (relasi satu-ke-satu dengan Pengguna). |
| **Media_Sosial** | id_media_sosial, id_pengguna, nama_media_sosial, link_media_sosial | Menyimpan tautan media sosial mahasiswa sebagai kontak tambahan pada profil. |
| **Data_Minat** | id_minat, id_pengguna, minat, deskripsi_minat | Menyimpan minat mahasiswa yang menjadi dasar pencarian dan penilaian kesesuaian. |
| **Data_Keahlian** | id_keahlian, id_pengguna, keahlian, deskripsi_keahlian | Menyimpan keahlian mahasiswa yang menjadi dasar pencarian dan penilaian kesesuaian. |
| **Data_Pengalaman** | id_pengalaman, id_pengguna, nama_kegiatan, peran, tahun, bukti_pendukung | Menyimpan pengalaman mahasiswa beserta bukti pendukung berupa foto atau dokumen. |
| **Data_Tim** | id_tim, id_pengguna (pembuat tim), nama_tim, nama_kegiatan, kategori_kegiatan, deskripsi, status_tim | Menyimpan informasi tim yang dibuat mahasiswa untuk suatu kegiatan. |
| **Kebutuhan_Tim** | id_kebutuhan, id_tim, posisi_dibutuhkan, keahlian_dibutuhkan, jumlah_anggota_dibutuhkan | Menyimpan kebutuhan anggota suatu tim (posisi, keahlian, dan jumlah). |
| **Dokumen_Pendukung** | id_dokumen, id_tim, jenis_dokumen, nama_file, path_file, urutan | Menyimpan dokumen pendukung tim, seperti poster atau panduan kegiatan. |
| **Anggota_Tim** | id_anggota_tim, id_tim, id_pengguna, posisi | Menyimpan data mahasiswa yang telah diterima dan bergabung dalam suatu tim. |
| **Pengajuan_Bergabung_Tim** | id_pengajuan_bergabung_tim, id_tim, id_pengguna, pesan_pengajuan, waktu_pengajuan, status_pengajuan | Menyimpan pengajuan pencari tim untuk bergabung ke tim beserta statusnya, yaitu menunggu, diterima, atau ditolak. |
| **Pengajuan_Anggota** | id_pengajuan_anggota, id_tim, id_pengguna, pesan_pengajuan, waktu_pengajuan, status_pengajuan | Menyimpan pengajuan pembuat tim kepada calon anggota untuk bergabung ke tim beserta statusnya, yaitu menunggu, diterima, atau ditolak. |
| **Notifikasi** | id_notifikasi, id_pengguna, id_pengajuan_bergabung_tim, id_pengajuan_anggota, jenis_notifikasi, pesan_notifikasi, waktu_notifikasi, status_dibaca | Menyimpan notifikasi untuk pengguna terkait pembaruan data riwayat diri, pengajuan bergabung, pengajuan anggota, dan perubahan statusnya. |

### 2.6 Constraints & Assumptions

#### Constraints

- Aplikasi dikembangkan menggunakan Flutter untuk perangkat dengan sistem operasi Android versi minimal 8.0.
- Aplikasi membutuhkan koneksi internet untuk menjalankan fungsi yang memerlukan pertukaran dan pembaruan data antarpengguna.
- Data aplikasi, termasuk file bukti pendukung dan dokumen pendukung tim, disimpan menggunakan database yang mendukung pertukaran data antarpengguna dan tidak menggunakan Firebase Storage.
- Aplikasi tidak menggunakan admin sebagai aktor utama sehingga proses utama dilakukan secara langsung antarmahasiswa.
- Pengunggahan foto profil, bukti pendukung pengalaman, dan dokumen pendukung tim memerlukan izin akses terhadap kamera, galeri, atau penyimpanan perangkat.

#### Assumptions

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
- Pengguna dapat membuat tim, mengajukan permintaan bergabung, mengajukan permintaan kepada calon anggota, serta menerima atau menolak pengajuan melalui aplikasi.
- Pengguna dapat mengetahui status pengajuan bergabung dan menerima notifikasi terkait pengajuan atau perubahan statusnya.
- Pengguna dapat menemukan dan membentuk tim sesuai dengan kebutuhan kegiatan yang diikuti.

---

## 3. Scope

### 3.1 In Scope

- Pengelolaan akun dan data riwayat diri mahasiswa, termasuk pendaftaran, login, informasi diri dan pendidikan, keahlian, minat, pengalaman beserta bukti pendukung, media sosial, foto profil, preferensi pencarian, dan informasi tim yang diikuti.
- Pembuatan tim, termasuk pembuatan, penampilan, pengubahan, dan penghapusan tim beserta kebutuhan anggota dan dokumen pendukung (poster atau panduan kegiatan).
- Pencarian tim (feed tim terbaru, pencarian, dan penyaringan) serta pencarian calon anggota berdasarkan nama, keahlian, pengalaman, dan minat, termasuk penampilan detail tim dan profil calon anggota.
- Pengajuan bergabung dua arah, yaitu pengajuan pencari tim ke tim beserta penerimaan atau penolakan oleh pembuat tim, serta pengajuan pembuat tim kepada calon anggota beserta penerimaan atau penolakan oleh calon anggota, termasuk melihat status pengajuan.
- Notifikasi terkait pembaruan data riwayat diri, pengajuan bergabung ke tim, pengajuan kepada calon anggota beserta responsnya, dan perubahan status pengajuan.

### 3.2 Out of Scope

- Penyediaan daftar atau katalog kegiatan, seperti lomba, penelitian, proyek, atau kegiatan lainnya.
- Pendaftaran resmi ke suatu kegiatan melalui aplikasi.
- Pengelolaan tim setelah proses pembentukan tim selesai, seperti pembagian tugas, jadwal, dan progres kegiatan.
- Fitur chat atau komunikasi langsung antarmahasiswa di dalam aplikasi.
- Sistem pembayaran atau transaksi dalam aplikasi.
- Sistem rekomendasi tim atau anggota menggunakan AI atau machine learning.
- Pengelolaan aplikasi oleh admin sebagai aktor utama.
- Penggunaan Firebase Storage untuk menyimpan data atau file aplikasi.

---

## 4. AI Prompt Context

### Project Overview

MyTeam adalah aplikasi mobile Android (dibangun dengan Flutter) yang membantu mahasiswa Universitas Andalas menemukan, membentuk, dan bergabung dengan tim untuk kegiatan seperti lomba, penelitian, atau proyek, berdasarkan minat, keahlian, dan pengalaman, tanpa memerlukan peran admin.

### Target User

Mahasiswa aktif Universitas Andalas dengan dua peran, yaitu pencari tim (mencari dan bergabung ke tim yang sesuai dengan minat, keahlian, dan pengalamannya) dan pencari anggota (membuat tim serta mencari anggota dengan keahlian tertentu). Satu mahasiswa dapat memiliki kedua peran tersebut.

### Project Goal

Menyediakan wadah bagi mahasiswa untuk menemukan, membentuk, dan bergabung dengan tim berdasarkan minat, keahlian, pengalaman, dan kebutuhan kegiatan. Mempermudah dan mempercepat proses pencarian serta pembentukan tim mahasiswa, menggantikan cara pencarian manual anggota tim melalui berbagai grup dan media komunikasi.

### Core Features

- **Akun & Data Riwayat Diri** — mahasiswa membuat akun dan mengelola informasi diri, pendidikan, keahlian, minat, pengalaman beserta bukti pendukung, serta preferensi pencarian sebagai dasar penilaian kesesuaian tim.
- **Pembuatan Tim** — mahasiswa membuat, melihat, mengubah, dan menghapus tim beserta kebutuhan anggota dan dokumen pendukung untuk suatu kegiatan.
- **Pencarian Tim & Pengajuan Bergabung** — pencari tim melihat feed tim, mencari dan menyaring tim, serta mengajukan permintaan bergabung; pembuat tim melihat serta menerima atau menolak pengajuan.
- **Pencarian Anggota & Pengajuan Anggota** — pembuat tim mencari calon anggota berdasarkan nama, keahlian, pengalaman, dan minat, melihat profil calon anggota, serta mengajukan permintaan bergabung yang dapat diterima atau ditolak calon anggota.
- **Notifikasi** — memberikan informasi kepada pengguna mengenai pembaruan data riwayat diri, pengajuan bergabung, pengajuan kepada calon anggota, dan perubahan status pengajuan.

### Constraints

- Platform Android minimal versi 8.0 (Oreo), dibangun menggunakan Flutter.
- Backend dan penyimpanan data (termasuk file bukti pendukung dan dokumen pendukung tim) menggunakan server/database lokal, tidak menggunakan Firebase.
- Interaksi murni antar mahasiswa (user-to-user) tanpa peran admin/moderator sebagai aktor utama.
- Tidak ada fitur chat/in-app messaging; koordinasi lanjutan dilakukan di luar aplikasi menggunakan kontak pada profil.
- Tidak ada rekomendasi tim berbasis AI/machine learning (di luar scope aplikasi).
- Membutuhkan izin akses kamera dan galeri/penyimpanan perangkat untuk foto profil, bukti pendukung pengalaman, dan dokumen pendukung tim.

### Expected AI Output

Bantuan menyusun/menyempurnakan struktur database (ERD) dari data requirements di atas, merancang wireframe atau alur UI/UX untuk setiap modul, menyusun test case dari functional requirements, serta memberi masukan terhadap konsistensi antara functional requirements, core features, dan logika transaksional CRUD sederhana untuk keempat modul (Data Riwayat Diri, Pembuatan Tim, Pencarian Tim & Pengajuan Bergabung, serta Pencarian Anggota & Pengajuan Anggota), tanpa menambahkan algoritma AI/ML/IoT di luar yang sudah didefinisikan.

---

## PRD Checklist

- [x] Problem statement jelas dan berfokus pada pengguna.
- [x] Target users spesifik.
- [x] Project goal menjawab masalah yang diidentifikasi.
- [x] Core features berjumlah sekitar 4–6 dan relevan.
- [x] User flow utama sudah dituliskan.
- [x] Data utama sudah diidentifikasi.
- [x] Constraints dan assumptions sudah dicatat.
- [x] Success criteria dapat digunakan untuk menilai hasil project.
- [x] In Scope dan Out of Scope sudah jelas.
- [x] Functional requirements menjelaskan perilaku/fungsi yang harus dilakukan aplikasi.
- [x] Non-functional requirements menjelaskan kualitas atau batasan sistem dan, jika memungkinkan, dapat diukur.
- [x] Functional requirements konsisten dengan core features.
- [x] Non-functional requirements tidak ditulis sebagai fitur baru.
