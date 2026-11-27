import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

def set_cell_background(cell, fill_hex):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>')
    tcPr.append(shd)

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = parse_xml(f'<w:tcMar {nsdecls("w")}><w:top w:w="{top}" w:type="dxa"/><w:bottom w:w="{bottom}" w:type="dxa"/><w:left w:w="{left}" w:type="dxa"/><w:right w:w="{right}" w:type="dxa"/></w:tcMar>')
    tcPr.append(tcMar)

def create_report():
    doc = docx.Document()

    # Set page margins (Normal: 1 inch)
    for section in doc.sections:
        section.top_margin = Inches(1)
        section.bottom_margin = Inches(1)
        section.left_margin = Inches(1)
        section.right_margin = Inches(1)

    # Styles
    normal_style = doc.styles['Normal']
    normal_style.font.name = 'Calibri'
    normal_style.font.size = Pt(11)
    normal_style.font.color.rgb = RGBColor(51, 51, 51)

    # Helper function for headings
    def add_custom_heading(text, level, color=RGBColor(26, 82, 118)):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(14)
        p.paragraph_format.space_after = Pt(4)
        p.paragraph_format.keep_with_next = True
        run = p.add_run(text)
        run.bold = True
        run.font.name = 'Calibri'
        if level == 1:
            run.font.size = Pt(16)
            run.font.color.rgb = color
            # Add bottom border/rule under H1
        elif level == 2:
            run.font.size = Pt(13)
            run.font.color.rgb = RGBColor(41, 128, 185)
        elif level == 3:
            run.font.size = Pt(11.5)
            run.font.color.rgb = RGBColor(44, 62, 80)
        return p

    def add_callout(text, title="CATATAN PENTING"):
        tbl = doc.add_table(rows=1, cols=1)
        tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
        tbl.autofit = False
        cell = tbl.cell(0, 0)
        cell.width = Inches(6.5)
        set_cell_background(cell, "EBF5FB")
        set_cell_margins(cell, top=120, bottom=120, left=180, right=180)
        p = cell.paragraphs[0]
        p.paragraph_format.space_after = Pt(2)
        r_title = p.add_run(f"📌 {title}: ")
        r_title.bold = True
        r_title.font.size = Pt(10)
        r_title.font.color.rgb = RGBColor(26, 82, 118)
        r_text = p.add_run(text)
        r_text.font.size = Pt(10)
        doc.add_paragraph().paragraph_format.space_after = Pt(4)

    def add_code_block(code_text):
        tbl = doc.add_table(rows=1, cols=1)
        tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
        tbl.autofit = False
        cell = tbl.cell(0, 0)
        cell.width = Inches(6.5)
        set_cell_background(cell, "F8F9F9")
        set_cell_margins(cell, top=100, bottom=100, left=150, right=150)
        p = cell.paragraphs[0]
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after = Pt(0)
        p.paragraph_format.line_spacing = 1.05
        run = p.add_run(code_text)
        run.font.name = 'Consolas'
        run.font.size = Pt(8.5)
        run.font.color.rgb = RGBColor(40, 40, 40)
        doc.add_paragraph().paragraph_format.space_after = Pt(6)

    # ================= COVER / HEADER =================
    title_p = doc.add_paragraph()
    title_p.paragraph_format.space_before = Pt(10)
    title_p.paragraph_format.space_after = Pt(4)
    title_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run_t1 = title_p.add_run("LAPORAN PRAKTIKUM 8\nPEMROGRAMAN MOBILE\n")
    run_t1.bold = True
    run_t1.font.size = Pt(18)
    run_t1.font.color.rgb = RGBColor(21, 67, 96)

    sub_p = doc.add_paragraph()
    sub_p.paragraph_format.space_after = Pt(16)
    sub_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run_t2 = sub_p.add_run("Pengembangan Model Admin & Implementasi Operasi CRUD (GET, POST, PUT, PATCH, DELETE) Menggunakan REST API dan Penyimpanan Lokal pada Flutter")
    run_t2.italic = True
    run_t2.font.size = Pt(12)
    run_t2.font.color.rgb = RGBColor(86, 101, 115)

    # Table Identitas
    id_table = doc.add_table(rows=5, cols=2)
    id_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    id_table.autofit = False
    col_widths = [Inches(2.5), Inches(4.0)]

    info_data = [
        ("Nama Mahasiswa", "Anggiant Dwi Raka"),
        ("NIM", "20240801120"),
        ("Mata Kuliah", "Pemrograman Mobile"),
        ("Nilai Variabel N (3 Digit NIM)", "120"),
        ("Perhitungan ID Praktikum", "ID User = 1499 + 120 = 1619\nID Admin = 792 + 120 = 912")
    ]

    for i, (label, val) in enumerate(info_data):
        row = id_table.rows[i]
        c0, c1 = row.cells[0], row.cells[1]
        c0.width = col_widths[0]
        c1.width = col_widths[1]
        set_cell_margins(c0, 60, 60, 100, 100)
        set_cell_margins(c1, 60, 60, 100, 100)
        set_cell_background(c0, "EAEDED")
        set_cell_background(c1, "F4F6F6")
        
        p0 = c0.paragraphs[0]
        p0.paragraph_format.space_after = Pt(0)
        r0 = p0.add_run(label)
        r0.bold = True
        r0.font.size = Pt(10)

        p1 = c1.paragraphs[0]
        p1.paragraph_format.space_after = Pt(0)
        r1 = p1.add_run(val)
        r1.font.size = Pt(10)
        if "1619" in val or "912" in val or "Anggiant" in val:
            r1.bold = True

    doc.add_paragraph().paragraph_format.space_after = Pt(10)

    # ================= BAB I =================
    add_custom_heading("I. PENDAHULUAN & KETENTUAN PRAKTIKUM", 1)
    
    p = doc.add_paragraph()
    p.add_run("Praktikum ini bertujuan untuk mengembangkan aplikasi mobile berbasis Flutter dengan mengimplementasikan arsitektur pemisahan ")
    r_b = p.add_run("Model")
    r_b.bold = True
    p.add_run(" dan ")
    r_b2 = p.add_run("Service")
    r_b2.bold = True
    p.add_run(". Pada praktikum sebelumnya, telah dibuat Model User beserta ApiService dengan operasi CRUD (GET, POST, PUT, PATCH, dan DELETE). Pada tahap pengembangan ini, ditambahkan Model baru bernama Admin dengan kebutuhan pengelolaan data yang berbeda.")

    p2 = doc.add_paragraph()
    p2.add_run("Ketentuan perhitungan angka praktikum berdasarkan NIM (")
    p2.add_run("20240801120").bold = True
    p2.add_run("):")

    bullets = [
        ("Nilai N", "Tiga digit terakhir NIM = 120."),
        ("ID User", "1499 + N = 1499 + 120 = 1619."),
        ("ID Admin", "792 + N = 792 + 120 = 912.")
    ]
    for b_title, b_desc in bullets:
        bp = doc.add_paragraph(style='List Bullet')
        bp.paragraph_format.space_after = Pt(2)
        r = bp.add_run(f"{b_title}: ")
        r.bold = True
        bp.add_run(b_desc)

    # ================= BAB II =================
    add_custom_heading("II. STRUKTUR ARSITEKTUR & FILE PROYEK", 1)
    p = doc.add_paragraph()
    p.add_run("Proyek Flutter diatur secara modular dan terpisah sesuai kaidah clean architecture, di mana setiap entitas memiliki file Model dan file Service tersendiri:")

    code_tree = """lib/
├── main.dart                      # UI Utama (Bottom Navigation Bar, List User, List Admin, Detail & API Tester)
├── models/
│   ├── user_model.dart            # Model User (id, name, email, city)
│   └── admin.dart                 # Model Admin (id, name, email, department)
├── services/
│   ├── api_service.dart           # Service CRUD User (GET, POST 1619, PUT, PATCH, DELETE)
│   └── admin_service.dart         # Service Admin (getAdmins, getAdmin 912, deleteAdmin 912)
└── l10n/
    ├── app_en.arb                 # String resource localization English
    ├── app_id.arb                 # String resource localization Bahasa Indonesia
    └── app_localizations.dart     # Localization delegate Flutter"""
    add_code_block(code_tree)

    add_callout("Model dan Service dipisahkan secara ketat untuk User dan Admin guna menjamin modularitas kode, kemudahan pengujian, dan pemeliharaan jangka panjang.", "KETENTUAN STRUKTUR FILE")

    # ================= BAB III =================
    add_custom_heading("III. IMPLEMENTASI MODEL DATA", 1)

    add_custom_heading("3.1 Model User (lib/models/user_model.dart)", 2)
    p = doc.add_paragraph()
    p.add_run("Model User merepresentasikan entitas pengguna dengan properti: id, name, email, dan city. Konstruktor factory fromJson dirancang fleksibel untuk membaca format alamat bertingkat (seperti JSONPlaceholder address.city) maupun format langsung (city).")

    user_code = """class User {
  final int id;
  final String name;
  final String email;
  final String city;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.city,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String parsedCity = '';
    if (json['address'] != null && json['address'] is Map) {
      parsedCity = json['address']['city']?.toString() ?? '';
    } else if (json['city'] != null) {
      parsedCity = json['city'].toString();
    }

    return User(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      city: parsedCity,
      email: json['email']?.toString() ?? '',
    );
  }
}"""
    add_code_block(user_code)

    add_custom_heading("3.2 Model Admin (lib/models/admin.dart)", 2)
    p = doc.add_paragraph()
    p.add_run("Model Admin merupakan model baru sesuai penugasan praktikum dengan properti: id, name, email, dan department. Factory fromJson mengonversi data JSON dan menangani pemetaan atribut department.")

    admin_code = """class Admin {
  final int id;
  final String name;
  final String email;
  final String department;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    String dept = '';
    if (json['company'] != null && json['company'] is Map) {
      dept = json['company']['name']?.toString() ?? '';
    } else if (json['department'] != null) {
      dept = json['department'].toString();
    }

    return Admin(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      department: dept,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
    };
  }
}"""
    add_code_block(admin_code)

    # ================= BAB IV =================
    add_custom_heading("IV. IMPLEMENTASI SERVICE LAYER & METODE HTTP", 1)

    add_custom_heading("4.1 ApiService User (lib/services/api_service.dart)", 2)
    p = doc.add_paragraph()
    p.add_run("ApiService bertanggung jawab mengelola data User. Mengingat API publik seperti JSONPlaceholder hanya bersifat mock (tidak menyimpan perubahan secara permanen di server cloud), ApiService mengombinasikan pemanggilan HTTP REST API nyata sekaligus melakukan persistensi lokal menggunakan JSON file melalui path_provider. Dengan demikian, data yang ditambahkan (POST), diubah (PUT/PATCH), dan dihapus (DELETE) langsung terefleksi secara nyata pada tampilan aplikasi.")

    crud_table = doc.add_table(rows=6, cols=3)
    crud_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    crud_table.autofit = False
    t_widths = [Inches(1.2), Inches(2.3), Inches(3.0)]

    headers = ["Metode", "Endpoint / Fungsi", "Keterangan Operasi"]
    for j, h in enumerate(headers):
        c = crud_table.cell(0, j)
        c.width = t_widths[j]
        set_cell_background(c, "1F618D")
        p = c.paragraphs[0]
        r = p.add_run(h)
        r.bold = True
        r.font.color.rgb = RGBColor(255, 255, 255)
        r.font.size = Pt(9.5)

    crud_rows = [
        ("GET", "getUsers() & getUser(id)", "Mengambil seluruh data user atau satu user spesifik berdasarkan ID."),
        ("POST", "createUser(name, email)", "Menambahkan data User baru dengan ID wajib bernilai 1619 (1499 + 120)."),
        ("PUT", "updateUser(id, name, email)", "Memperbarui data User secara menyeluruh (mengganti nama & email)."),
        ("PATCH", "patchUser(id, name)", "Memperbarui nama User dengan menambahkan imbuhan teks ' - Flutter Developer'."),
        ("DELETE", "deleteUser(id)", "Menghapus data User dari sistem berdasarkan ID yang diberikan.")
    ]

    for i, (m, ep, desc) in enumerate(crud_rows, start=1):
        row = crud_table.rows[i]
        for col_idx, val in enumerate([m, ep, desc]):
            cell = row.cells[col_idx]
            cell.width = t_widths[col_idx]
            set_cell_margins(cell, 40, 40, 80, 80)
            if i % 2 == 1:
                set_cell_background(cell, "F2F4F4")
            p = cell.paragraphs[0]
            p.paragraph_format.space_after = Pt(0)
            r = p.add_run(val)
            r.font.size = Pt(9)
            if col_idx == 0:
                r.bold = True

    doc.add_paragraph().paragraph_format.space_after = Pt(8)

    add_custom_heading("4.2 AdminService (lib/services/admin_service.dart)", 2)
    p = doc.add_paragraph()
    p.add_run("AdminService menangani operasi data Admin dengan ketentuan khusus praktikum:")

    admin_bullets = [
        ("getAdmins()", "Mengambil daftar seluruh Admin dalam bentuk List<Admin>."),
        ("getAdmin(id)", "Mengambil satu objek Admin berdasarkan ID. Khusus pengujian menggunakan ID Admin = 912 (792 + 120)."),
        ("deleteAdmin(id)", "Menghapus data Admin tertentu berdasarkan ID (ID 912). Operasi mengirimkan HTTP DELETE ke API dan menghapus data pada penyimpanan lokal.")
    ]
    for b_title, b_desc in admin_bullets:
        bp = doc.add_paragraph(style='List Bullet')
        bp.paragraph_format.space_after = Pt(2)
        r = bp.add_run(f"{b_title}: ")
        r.bold = True
        bp.add_run(b_desc)

    # ================= BAB V =================
    add_custom_heading("V. IMPLEMENTASI ANTARMUKA PENGGUNA (UI)", 1)
    p = doc.add_paragraph()
    p.add_run("Aplikasi dibangun dengan Flutter Material 3 yang elegan dan responsif, terdiri dari komponen-komponen berikut:")

    ui_list = [
        ("Bottom Navigation Bar", "Menyediakan navigasi cepat antara halaman Users (Warna Primer Biru) dan Admins (Warna Primer Ungu)."),
        ("Halaman Daftar User (UserListPage)", "Menampilkan daftar seluruh User dalam Card & ListTile. Dilengkapi Floating Action Button (FAB) 'Test API User' menuju form pengujian CRUD."),
        ("Halaman Detail User (UserDetailPage)", "Menampilkan rincian data User (ID, Nama, Email, dan Kota) dengan Avatar dan Card informatif."),
        ("Halaman Daftar Admin (AdminListPage)", "Menampilkan daftar seluruh Admin. Admin NIM (ID 912) otomatis diberi highlight dan badge 'NIM: 20240801120' khusus. Dilengkapi FAB 'Cari Admin' untuk mencari berdasarkan ID."),
        ("Halaman Detail Admin (AdminDetailPage)", "Menampilkan rincian Admin (ID, Nama, Email, Department) dan tombol aksi penghapusan (DELETE) baik di AppBar maupun tombol aksi besar dengan konfirmasi AlertDialog."),
        ("Halaman API Method Tester (ApiTesterScreen)", "Form interaktif pengujian method GET, POST, PUT, PATCH, dan DELETE dengan dropdown method, input fields, tombol kirim, dan tampilan JSON response berformat rapi.")
    ]

    for title, desc in ui_list:
        bp = doc.add_paragraph(style='List Bullet')
        bp.paragraph_format.space_after = Pt(3)
        bp.add_run(f"{title}: ").bold = True
        bp.add_run(desc)

    # ================= BAB VI =================
    add_custom_heading("VI. HASIL PENGUJIAN DAN SCREENSHOT FITUR", 1)
    p = doc.add_paragraph()
    p.add_run("Pengujian dilakukan terhadap seluruh fungsionalitas yang disyaratkan dalam tugas praktikum. Berikut adalah ringkasan hasil pengujian:")

    test_table = doc.add_table(rows=8, cols=4)
    test_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    test_table.autofit = False
    test_widths = [Inches(0.6), Inches(1.8), Inches(2.6), Inches(1.5)]

    t_headers = ["No", "Fitur / Skenario", "Input & Operasi", "Status Hasil"]
    for j, h in enumerate(t_headers):
        c = test_table.cell(0, j)
        c.width = test_widths[j]
        set_cell_background(c, "273746")
        p = c.paragraphs[0]
        r = p.add_run(h)
        r.bold = True
        r.font.color.rgb = RGBColor(255, 255, 255)
        r.font.size = Pt(9.5)

    test_cases = [
        ("1", "User - GET All", "Membuka tab Users", "Berhasil (10 Data Dimuat)"),
        ("2", "User - POST (NIM)", "Pilih POST, Nama: Anggiant Dwi Raka, Email: anggiant@mail.com", "Berhasil (Tersimpan ID 1619)"),
        ("3", "User - PUT", "Pilih PUT, ID: 1619, Ubah Nama & Email", "Berhasil (Data Terganti)"),
        ("4", "User - PATCH", "Pilih PATCH, ID: 1619, Nama: Anggiant", "Berhasil ('... - Flutter Developer')"),
        ("5", "User - DELETE", "Pilih DELETE, ID: 1619", "Berhasil (User Terhapus)"),
        ("6", "Admin - GET (All & by ID)", "Buka tab Admins, Cari ID: 912", "Berhasil (Tampil Admin 912)"),
        ("7", "Admin - DELETE", "Tekan ikon Hapus pada Detail Admin 912", "Berhasil (Admin 912 Dihapus)")
    ]

    for i, (no, feat, op, res) in enumerate(test_cases, start=1):
        row = test_table.rows[i]
        for col_idx, val in enumerate([no, feat, op, res]):
            cell = row.cells[col_idx]
            cell.width = test_widths[col_idx]
            set_cell_margins(cell, 40, 40, 60, 60)
            if i % 2 == 1:
                set_cell_background(cell, "F8F9F9")
            p = cell.paragraphs[0]
            p.paragraph_format.space_after = Pt(0)
            r = p.add_run(val)
            r.font.size = Pt(8.5)
            if col_idx == 3:
                r.bold = True
                r.font.color.rgb = RGBColor(39, 174, 96)

    doc.add_paragraph().paragraph_format.space_after = Pt(10)

    # Screenshot placeholders
    add_custom_heading("Panduan Penempatan Screenshot Bukti Pengujian:", 3)
    p = doc.add_paragraph()
    p.add_run("Untuk melengkapi laporan, tempelkan tangkapan layar (screenshot) aplikasi pada area kotak di bawah ini saat aplikasi dijalankan di Emulator atau Perangkat Android/Windows:")

    ss_boxes = [
        "Screenshot 1: Tampilan Halaman Daftar User (User List)",
        "Screenshot 2: Tampilan Halaman Pengujian API Tester (POST User Baru ID 1619)",
        "Screenshot 3: Tampilan Halaman Pengujian API Tester (PATCH User ' - Flutter Developer')",
        "Screenshot 4: Tampilan Halaman Daftar Admin dengan Highlight Admin NIM 912",
        "Screenshot 5: Tampilan Halaman Detail Admin ID 912",
        "Screenshot 6: Tampilan Dialog Konfirmasi & Hasil Penghapusan Admin ID 912"
    ]

    for title in ss_boxes:
        tbl = doc.add_table(rows=1, cols=1)
        tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
        tbl.autofit = False
        cell = tbl.cell(0, 0)
        cell.width = Inches(6.5)
        set_cell_background(cell, "FBFCFC")
        set_cell_margins(cell, top=140, bottom=140, left=150, right=150)
        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        r1 = p.add_run(f"📸 [TEMPELKAN DI SINI: {title}]\n")
        r1.bold = True
        r1.font.size = Pt(9.5)
        r1.font.color.rgb = RGBColor(127, 140, 141)
        r2 = p.add_run("(Ukuran gambar disarankan proporsional dengan lebar halaman)")
        r2.italic = True
        r2.font.size = Pt(8.5)
        r2.font.color.rgb = RGBColor(189, 195, 199)
        doc.add_paragraph().paragraph_format.space_after = Pt(6)

    # ================= BAB VII =================
    add_custom_heading("VII. KESIMPULAN", 1)
    p = doc.add_paragraph()
    p.add_run("Berdasarkan hasil perancangan, implementasi, dan pengujian pada Praktikum 8 Pemrograman Mobile ini, dapat diambil kesimpulan sebagai berikut:\n")
    
    conclusions = [
        "Pemisahan kode menjadi lapisan Model (user_model.dart, admin.dart) dan Service (api_service.dart, admin_service.dart) meningkatkan kerapian, modularitas, dan pemeliharaan kode aplikasi Flutter.",
        "Model Admin berhasil diimplementasikan dengan 4 atribut (id, name, email, department) dan dilengkapi method getAdmins(), getAdmin(id), serta deleteAdmin(id) sesuai dengan rumus NIM (ID Admin = 792 + 120 = 912).",
        "Operasi CRUD User (GET, POST dengan ID NIM 1619, PUT, PATCH dengan penambahan string '- Flutter Developer', dan DELETE) berjalan dengan sempurna melalui perpaduan HTTP request REST API dan persistensi lokal.",
        "Antarmuka pengguna (UI) berhasil memfasilitasi seluruh kebutuhan interaksi, mulai dari tampilan daftar, pencarian, melihat detail, hingga menghapus data admin dengan dialog konfirmasi yang aman."
    ]
    for c in conclusions:
        bp = doc.add_paragraph(style='List Bullet')
        bp.paragraph_format.space_after = Pt(3)
        bp.add_run(c)

    doc.add_paragraph().paragraph_format.space_after = Pt(14)

    # Tanda Tangan
    sign_table = doc.add_table(rows=1, cols=2)
    sign_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    sign_table.autofit = False
    c_left = sign_table.cell(0, 0)
    c_right = sign_table.cell(0, 1)
    c_left.width = Inches(3.25)
    c_right.width = Inches(3.25)

    p_r = c_right.paragraphs[0]
    p_r.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_r.add_run("Praktikan,\n\n\n\n\n").font.size = Pt(10)
    r_name = p_r.add_run("Anggiant Dwi Raka\n")
    r_name.bold = True
    r_name.underline = True
    r_name.font.size = Pt(10)
    p_r.add_run("NIM. 20240801120").font.size = Pt(9.5)

    output_path = r"C:\SEMESTER 5\PEMMOB\pertemuan8\Laporan_Praktikum8_20240801120_Anggiant_Dwi_Raka.docx"
    doc.save(output_path)
    print(f"Report successfully saved to: {output_path}")

if __name__ == '__main__':
    create_report()
