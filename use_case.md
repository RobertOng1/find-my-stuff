# Skenario Pengujian Stabilitas Aplikasi "Find My Stuff"

Dokumen ini berisi daftar **Use Case** krusial yang harus diuji oleh tim testing untuk memastikan aplikasi berjalan stabil, minim bug, dan siap rilis. Fokus pengujian adalah pada fungsionalitas utama dan penanganan *error*.

---

## 1. Modul Otentikasi (Auth)

### **UC-01: Login & Sesi Pengguna**
*   **Tujuan:** Memastikan pengguna bisa masuk dan sesi tersimpan dengan benar.
*   **Skenario:**
    1.  Buka aplikasi dalam keadaan *logged out*.
    2.  Lakukan Login menggunakan **Google Sign-In**.
    3.  **Harapan:** Berhasil masuk ke Home Screen tanpa *crash*.
    4.  Tutup aplikasi (Kill App) dan buka kembali.
    5.  **Harapan:** Langsung masuk ke Home Screen (tidak diminta login ulang).

### **UC-02: Logout & Keamanan**
*   **Tujuan:** Memastikan data pengguna bersih saat keluar.
*   **Skenario:**
    1.  Masuk ke menu Profile -> Settings -> Logout.
    2.  **Harapan:** Kembali ke Login Screen.
    3.  Tekan tombol "Back" pada HP.
    4.  **Harapan:** Aplikasi tertutup atau tetap di Login Screen (tidak bisa balik ke Home tanpa login).

---

## 2. Modul Pelaporan (Core Feature)

### **UC-03: Membuat Laporan Kehilangan (Create Post)**
*   **Tujuan:** Memastikan fungsi upload dan validasi form berjalan.
*   **Skenario:**
    1.  Tekan tombol (+).
    2.  Isi Judul, Deskripsi, dan Lokasi.
    3.  **Stress Test:** Masukkan deskripsi yang sangat panjang (1000+ karakter).
    4.  Pilih Foto dari Galeri.
    5.  Tekan "Post".
    6.  **Harapan:** Loading indicator muncul, lalu sukses kembali ke Home, dan item muncul di *feed* paling atas.

### **UC-04: Upload Gagal (Negative Case)**
*   **Tujuan:** Menguji respon aplikasi saat data tidak lengkap.
*   **Skenario:**
    1.  Buka form Create Post.
    2.  Kosongkan Judul atau Foto.
    3.  Tekan "Post".
    4.  **Harapan:** Muncul pesan error "Please fill all fields" atau sejenisnya. Aplikasi tidak boleh *loading* selamanya.

---

## 3. Modul Chat & Komunikasi

### **UC-05: Realtime Chat (Text)**
*   **Tujuan:** Memastikan pesan terkirim instan tanpa delay.
*   **Skenario:**
    1.  Buka Chat dengan Pengguna B.
    2.  Kirim pesan teks "Tes Jaringan".
    3.  **Harapan:** Pesan muncul seketika di layar sendiri (optimistic UI) dan di HP Pengguna B dalam < 2 detik.
    4.  Cek daftar pesan (Message List).
    5.  **Harapan:** Chat tersebut ada di paling atas dengan cuplikan pesan yang benar.

### **UC-06: Voice Note Stability**
*   **Tujuan:** Menguji fitur rentan *crash* (akses mikrofon).
*   **Skenario:**
    1.  Tekan dan Tahan ikon mikrofon.
    2.  Rekam suara selama 5 detik.
    3.  Lepas untuk mengirim.
    4.  **Harapan:** Chat bubble audio muncul, bisa diputar, dan durasi sesuai.
    5.  **Skenario Batal:** Tahan mikrofon, *swipe* ke kiri (cancel).
    6.  **Harapan:** Rekaman batal, tidak ada pesan terkirim, timer reset ke 00:00.

### **UC-07: Legacy Chat Handling**
*   **Tujuan:** Memastikan chat lama tetap jalan meski ada update fitur baru.
*   **Skenario:**
    1.  Buka chat lama yang dibuat sebelum fitur "Unread Count" ada.
    2.  Minta lawan bicara mengirim pesan baru.
    3.  **Harapan:** Notifikasi muncul dengan Nama & Foto Profil yang benar (bukan "Someone"), dan badge unread muncul.

---

## 4. Modul Klaim & Verifikasi

### **UC-08: Flow Klaim Barang (Claimant)**
*   **Tujuan:** Memastikan alur pengajuan klaim.
*   **Skenario:**
    1.  Buka detail barang orang lain.
    2.  Tekan "Claim This Item".
    3.  Upload bukti foto dan deskripsi unik.
    4.  Submit.
    5.  **Harapan:** Status berubah menjadi "Pending Review".

### **UC-09: Verifikasi Bukti (Finder)**
*   **Tujuan:** Memastikan pemilik barang bisa memvalidasi klaim.
*   **Skenario:**
    1.  Login sebagai Penemu barang.
    2.  Buka notifikasi "New Claim".
    3.  Masuk ke layar Verifikasi.
    4.  **Cek Validasi:** Pastikan Trust Score dan Poin pengklaim muncul (bukan placeholder).
    5.  Tekan "Accept".
    6.  **Harapan:** Muncul dialog sukses, dan status barang berubah (tidak bisa diklaim orang lain lagi) ataupun hilang.

---

## 5. Notifikasi & Deep Linking

### **UC-10: Background Notification**
*   **Tujuan:** Memastikan notifikasi membawa user ke halaman yang tepat.
*   **Skenario:**
    1.  Tutup aplikasi (Kill App/Background).
    2.  Minta teman kirim chat.
    3.  Tunggu notifikasi muncul di System Tray HP.
    4.  Tekan notifikasi tersebut.
    5.  **Harapan:** Aplikasi terbuka dan **langsung masuk ke dalam Room Chat** pengirim tersebut (bukan nyasar ke Home).
