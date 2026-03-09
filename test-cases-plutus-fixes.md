# Plutus Mobile - Manual Test Cases for Testing Fixes

**Date:** 2026-03-09
**Build:** Staging
**Tester:** QA / PM

---

## F-002: Receipt Upload Silently Fails [S1 Critical]

### TC-002-01: Submit expense with receipt (scan flow)

| Step | Action | Expected |
|------|--------|----------|
| 1 | Buka app, tap **"Scan Receipt"** dari home screen | Kamera / gallery picker terbuka |
| 2 | Ambil foto receipt atau pilih dari gallery | Kembali ke form, receipt preview muncul dengan thumbnail |
| 3 | Tunggu OCR selesai | Badge berubah menjadi **"Extracted"**, form ter-autofill |
| 4 | Isi form lengkap (amount, vendor, category, date) | Form valid, tombol submit aktif |
| 5 | Tap **"Submit for Approval"** | Loading indicator muncul |
| 6 | Tunggu proses selesai | Navigasi ke success screen |
| 7 | Buka expense dari list, tap detail | Receipt **muncul** di section Receipts, bukan "Missing Receipt" |

**Pass:** Receipt tampil di expense detail setelah submit.
**Fail:** "Missing Receipt" atau receipt hilang.

---

### TC-002-02: Submit expense with receipt (manual attach di form)

| Step | Action | Expected |
|------|--------|----------|
| 1 | Tap **"New Expense"** dari home (manual entry) | Form expense terbuka, banner "Manual Entry" muncul |
| 2 | Isi form lengkap (amount, vendor, category, date) | Form valid |
| 3 | Scroll ke bawah, tap **"Scan Receipt"** | Bottom sheet muncul: "Take Photo" / "Choose from Gallery" |
| 4 | Pilih **"Take Photo"** atau **"Choose from Gallery"** | Kamera / gallery picker terbuka |
| 5 | Ambil / pilih gambar receipt | Kembali ke form, **thumbnail image** muncul di receipt preview |
| 6 | Tap **"Submit for Approval"** | Loading indicator, lalu navigasi ke success screen |
| 7 | Buka expense detail dari list | Receipt muncul di section Receipts |

**Pass:** Receipt ter-upload dan muncul di detail.
**Fail:** Receipt hilang setelah submit.

---

### TC-002-03: Receipt upload failure shows warning

| Step | Action | Expected |
|------|--------|----------|
| 1 | Matikan koneksi internet (airplane mode) **setelah** isi form tapi **sebelum** submit | - |
| 2 | Attach receipt via kamera/gallery | Receipt preview muncul di form |
| 3 | Tap **"Submit for Approval"** | Submit berjalan (atau gagal total) |
| 4 | Jika expense ter-create tapi receipt gagal upload | Muncul **notifikasi kuning**: "Receipt upload failed. You can attach it later from expense detail." |

**Pass:** User mendapat feedback jelas bahwa receipt gagal upload.
**Fail:** Tidak ada notifikasi, user tidak tahu receipt gagal.

---

### TC-002-04: State bersih setelah submit (no stale receipt)

| Step | Action | Expected |
|------|--------|----------|
| 1 | Buat expense baru dengan receipt attached | Receipt preview muncul |
| 2 | Submit expense (draft atau for approval) | Navigasi ke success screen |
| 3 | Tap **"New Expense"** lagi (manual entry) | Form expense terbuka **BERSIH** |
| 4 | Cek area receipt preview di atas form | **Tidak ada** receipt dari submission sebelumnya |
| 5 | Cek banner info | Banner "Manual Entry - needs receipt" muncul (karena belum attach) |

**Pass:** Form bersih, tidak ada sisa receipt dari submission sebelumnya.
**Fail:** Receipt dari submission sebelumnya masih muncul di form baru.

---

## F-003: Self-Approval Possible [S2 Major]

### TC-003-01: Manager tidak bisa approve expense sendiri

| Step | Action | Expected |
|------|--------|----------|
| 1 | Login sebagai **Manager** (jobLevel >= 3) | Dashboard manager terbuka |
| 2 | Buat expense baru → isi form lengkap | Form valid |
| 3 | Tap **"Submit for Approval"** | Expense ter-submit |
| 4 | Buka **sidebar** → tap **"Approvals"** | Approval inbox terbuka |
| 5 | Cari expense yang baru di-submit (nama requester = nama sendiri) | Expense muncul di list |
| 6 | Tap expense tersebut untuk buka detail | Detail screen terbuka |
| 7 | Scroll ke bawah, lihat area action buttons | **Tombol Approve / Reject / Return TIDAK MUNCUL** |
| 8 | Lihat banner di bawah layar | **Banner kuning** muncul: "You cannot approve your own expense. This task must be handled by another approver." |

**Pass:** Action buttons hidden, warning banner muncul.
**Fail:** Tombol Approve/Reject masih muncul dan bisa diklik.

---

### TC-003-02: Manager bisa approve expense orang lain (normal)

| Step | Action | Expected |
|------|--------|----------|
| 1 | Login sebagai **Manager** | Dashboard manager |
| 2 | Buka **sidebar** → **"Approvals"** | Approval inbox |
| 3 | Pilih expense dari **orang lain** (requester bukan diri sendiri) | - |
| 4 | Tap untuk buka detail | Detail screen terbuka |
| 5 | Lihat area action buttons di bawah | Tombol **"Approve"**, **"Reject"**, **"Return for Revision"** muncul normal |
| 6 | Tap **"Approve"** | Approval berhasil, navigasi ke success screen |

**Pass:** Flow approve normal untuk expense orang lain.
**Fail:** Tombol tidak muncul atau approve gagal.

---

## F-003b: Category Mismatch Between Screens [S2 Major]

### TC-003b-01: Category konsisten antara create dan approval screen

| Step | Action | Expected |
|------|--------|----------|
| 1 | Login sebagai **Employee** | Dashboard employee |
| 2 | Buat expense baru, pilih category **"Transportation"** | Category "Transportation" ter-select |
| 3 | Isi form lengkap, submit for approval | Expense ter-submit |
| 4 | **Catat** category yang dipilih: "Transportation" | - |
| 5 | Login sebagai **Manager** (approver) | Dashboard manager |
| 6 | Buka **"Approvals"** → cari expense yang baru di-submit | Expense muncul di inbox |
| 7 | Tap expense untuk buka detail | Detail screen terbuka |
| 8 | Lihat field **"Category"** di section Expense Details | Category = **"Transportation"** |

**Pass:** Category di approval screen **SAMA** dengan yang dipilih saat create.
**Fail:** Category berbeda (misal muncul "Meals" padahal dipilih "Transportation").

---

### TC-003b-02: Test dengan berbagai category

Ulangi TC-003b-01 dengan category berikut:

| Category dipilih | Expected di approval screen |
|------------------|-----------------------------|
| General | General |
| Meals | Meals |
| Transportation | Transportation |
| Office Supplies | Office Supplies |
| Travel | Travel |
| Flight | Flight |

**Pass:** Semua category match.
**Fail:** Ada category yang berubah.

### TC-003b-03: Category konsisten di inbox list DAN detail

| Step | Action | Expected |
|------|--------|----------|
| 1 | Login sebagai Employee, buat expense category **"Flight"** | Submit |
| 2 | Login sebagai Manager, buka **Approvals** | Inbox list muncul |
| 3 | Lihat category badge di **list item** | Category = **"Flight"** (bukan "Meals") |
| 4 | Tap expense untuk buka detail | Detail screen |
| 5 | Lihat field Category di **Expense Details** | Category = **"Flight"** (bukan "Uncategorized") |

**Pass:** Category "Flight" konsisten di list dan detail.
**Fail:** Category berubah jadi "Meals" di list atau "Uncategorized" di detail.

---

## F-004a: No Receipt Preview in Creation Form [S2 Major]

### TC-004a-01: Preview muncul setelah attach via kamera

| Step | Action | Expected |
|------|--------|----------|
| 1 | Tap **"New Expense"** (manual entry) | Form terbuka |
| 2 | Scroll ke bawah, tap **"Scan Receipt"** | Bottom sheet muncul |
| 3 | Pilih **"Take Photo"** → ambil foto receipt | Kembali ke form |
| 4 | Lihat receipt preview section | **Thumbnail image** dari foto muncul (bukan hanya icon dokumen) |
| 5 | Tap thumbnail | Preview fullscreen terbuka |

**Pass:** Thumbnail foto receipt muncul, bisa di-tap untuk fullscreen.
**Fail:** Hanya muncul icon dokumen / text tanpa preview gambar.

---

### TC-004a-02: Preview muncul setelah attach via gallery

| Step | Action | Expected |
|------|--------|----------|
| 1 | Tap **"New Expense"** | Form terbuka |
| 2 | Tap **"Scan Receipt"** → **"Choose from Gallery"** | Gallery picker terbuka |
| 3 | Pilih **1 gambar** receipt | Kembali ke form |
| 4 | Lihat receipt preview section | **Thumbnail image** muncul dengan gambar yang dipilih |

**Pass:** Thumbnail gambar dari gallery muncul.
**Fail:** Hanya icon/text, tidak ada preview gambar.

---

### TC-004a-03: Multiple receipt thumbnails

| Step | Action | Expected |
|------|--------|----------|
| 1 | Tap **"New Expense"** | Form terbuka |
| 2 | Tap **"Scan Receipt"** → **"Choose from Gallery"** | Gallery picker terbuka |
| 3 | Pilih **2-3 gambar** sekaligus | Kembali ke form |
| 4 | Lihat receipt preview section | **Horizontal thumbnail strip** muncul, bisa di-scroll |
| 5 | Cek header | Tertulis **"Receipts (3)"** (sesuai jumlah) |
| 6 | Tap salah satu thumbnail | Preview fullscreen gambar tersebut |

**Pass:** Semua thumbnail muncul sebagai image, bisa scroll horizontal.
**Fail:** Hanya icon/text, atau jumlah tidak sesuai.

---

## F-004b: Conflicting UI Messages on Receipt Status [S3 Minor]

### TC-004b-01: Banner hilang setelah attach receipt

| Step | Action | Expected |
|------|--------|----------|
| 1 | Tap **"New Expense"** (manual entry, bukan dari scan) | Form terbuka |
| 2 | Lihat banner biru di atas form | Banner muncul: **"Manual Entry - This expense will need a receipt attachment before submission."** |
| 3 | Scroll ke bawah, tap **"Scan Receipt"** | Bottom sheet muncul |
| 4 | Attach receipt (kamera atau gallery) | Kembali ke form dengan receipt preview |
| 5 | Scroll ke atas, cek area banner | Banner **"Manual Entry" HILANG** |
| 6 | Tidak ada pesan konflik | Hanya receipt preview section yang tampil |

**Pass:** Banner hilang setelah receipt attached. Tidak ada pesan konflik.
**Fail:** Banner masih muncul bersamaan dengan receipt preview ("needs receipt" + "receipt attached").

---

### TC-004b-02: Banner muncul kembali jika receipt dihapus

| Step | Action | Expected |
|------|--------|----------|
| 1 | Lanjut dari TC-004b-01 (receipt sudah attached, banner hidden) | - |
| 2 | Di receipt preview section, tap tombol **X** / hapus semua receipt | Receipt terhapus |
| 3 | Scroll ke atas, cek area banner | Banner **"Manual Entry"** **MUNCUL KEMBALI** |

**Pass:** Banner muncul kembali saat receipt dihapus.
**Fail:** Banner tidak muncul kembali.

---

### TC-004b-03: Dari scan flow, banner tidak muncul

| Step | Action | Expected |
|------|--------|----------|
| 1 | Dari home screen, tap **"Scan Receipt"** | Kamera terbuka |
| 2 | Ambil foto receipt, tunggu OCR | Form terbuka dengan receipt preview |
| 3 | Lihat area di atas form (di atas receipt preview) | Banner **"Manual Entry" TIDAK MUNCUL** |

**Pass:** Tidak ada banner "needs receipt" saat sudah ada receipt dari scan.
**Fail:** Banner muncul padahal receipt sudah ada.

---

## F-001: Company Name di Sidebar [S2 - Partial Fix]

### TC-001-01: Department muncul di sidebar header

| Step | Action | Expected |
|------|--------|----------|
| 1 | Login dengan akun yang punya department (misal "Finance") | Login berhasil |
| 2 | Tap **hamburger icon** (kiri atas) untuk buka sidebar | Sidebar terbuka |
| 3 | Lihat header sidebar (area gradient dengan avatar) | - |
| 4 | Cek info yang tampil | Urutan: **Nama** (bold) → **Role badge + Level** → **Nama department** (putih transparan) |

**Expected layout:**
```
┌─────────────────────────────┐
│  [A]  Andi Prasetyo         │
│       Finance Manager  L4   │
│       Finance Department    │
└─────────────────────────────┘
```

**Pass:** Department name muncul di bawah role.
**Fail:** Department tidak muncul atau layout rusak.

---

### TC-001-02: User tanpa department

| Step | Action | Expected |
|------|--------|----------|
| 1 | Login dengan akun yang **tidak punya department** | Login berhasil |
| 2 | Buka sidebar | Sidebar terbuka |
| 3 | Lihat header | Hanya nama + role, **tidak ada** baris kosong atau crash |

**Pass:** Sidebar tampil normal tanpa department row.
**Fail:** Crash, error, atau baris kosong muncul.

---

## Summary Checklist

| # | ID | Test Case | Status | Notes |
|---|----|-----------|--------|-------|
| 1 | TC-002-01 | Receipt submit (scan flow) | ☐ | |
| 2 | TC-002-02 | Receipt submit (manual attach) | ☐ | |
| 3 | TC-002-03 | Receipt upload failure warning | ☐ | |
| 4 | TC-002-04 | No stale receipt on new form | ☐ | |
| 5 | TC-003-01 | Self-approval blocked | ☐ | |
| 6 | TC-003-02 | Approve others normal | ☐ | |
| 7 | TC-003b-01 | Category consistency | ☐ | |
| 8 | TC-003b-02 | Multiple categories | ☐ | |
| 9 | TC-004a-01 | Preview via camera | ☐ | |
| 10 | TC-004a-02 | Preview via gallery | ☐ | |
| 11 | TC-004a-03 | Multiple receipt thumbnails | ☐ | |
| 12 | TC-004b-01 | Banner hides on attach | ☐ | |
| 13 | TC-004b-02 | Banner reappears on remove | ☐ | |
| 14 | TC-004b-03 | No banner from scan flow | ☐ | |
| 15 | TC-001-01 | Department in sidebar | ☐ | |
| 16 | TC-001-02 | No department graceful | ☐ | |
