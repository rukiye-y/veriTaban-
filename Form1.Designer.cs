namespace hayvanatBahçesi
{
    partial class hayvanlar
    {
        /// <summary>
        ///Gerekli tasarımcı değişkeni.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///Kullanılan tüm kaynakları temizleyin.
        /// </summary>
        ///<param name="disposing">yönetilen kaynaklar dispose edilmeliyse doğru; aksi halde yanlış.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer üretilen kod

        /// <summary>
        /// Tasarımcı desteği için gerekli metot - bu metodun 
        ///içeriğini kod düzenleyici ile değiştirmeyin.
        /// </summary>
        private void InitializeComponent()
        {
            this.dataGridView1 = new System.Windows.Forms.DataGridView();
            this.bHEkle = new System.Windows.Forms.Button();
            this.bHSil = new System.Windows.Forms.Button();
            this.bhAra = new System.Windows.Forms.Button();
            this.bHGüncel = new System.Windows.Forms.Button();
            this.hAdl = new System.Windows.Forms.Label();
            this.hAd = new System.Windows.Forms.TextBox();
            this.hYas = new System.Windows.Forms.Label();
            this.cinsiyetT = new System.Windows.Forms.TextBox();
            this.cinsiyet = new System.Windows.Forms.Label();
            this.hid = new System.Windows.Forms.Label();
            this.hyasN = new System.Windows.Forms.NumericUpDown();
            this.turid = new System.Windows.Forms.Label();
            this.turidN = new System.Windows.Forms.NumericUpDown();
            this.hidN = new System.Windows.Forms.NumericUpDown();
            this.hliste = new System.Windows.Forms.Button();
            this.hsayısı = new System.Windows.Forms.Button();
            this.beslenmeözeti = new System.Windows.Forms.Button();
            this.eksikMiftar = new System.Windows.Forms.Button();
            this.toplamGelir = new System.Windows.Forms.Button();
            this.alanid = new System.Windows.Forms.NumericUpDown();
            this.label1 = new System.Windows.Forms.Label();
            this.id = new System.Windows.Forms.NumericUpDown();
            this.label2 = new System.Windows.Forms.Label();
            this.ilktarih = new System.Windows.Forms.DateTimePicker();
            this.sontarih = new System.Windows.Forms.DateTimePicker();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.tarih = new System.Windows.Forms.DateTimePicker();
            this.label5 = new System.Windows.Forms.Label();
            this.button1 = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.hyasN)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.turidN)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.hidN)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.alanid)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.id)).BeginInit();
            this.SuspendLayout();
            // 
            // dataGridView1
            // 
            this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView1.Location = new System.Drawing.Point(0, 0);
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.RowHeadersWidth = 51;
            this.dataGridView1.RowTemplate.Height = 24;
            this.dataGridView1.Size = new System.Drawing.Size(425, 264);
            this.dataGridView1.TabIndex = 0;
            // 
            // bHEkle
            // 
            this.bHEkle.Location = new System.Drawing.Point(542, 182);
            this.bHEkle.Name = "bHEkle";
            this.bHEkle.Size = new System.Drawing.Size(75, 29);
            this.bHEkle.TabIndex = 1;
            this.bHEkle.Text = "ekle";
            this.bHEkle.UseVisualStyleBackColor = true;
            this.bHEkle.Click += new System.EventHandler(this.bHEkle_Click);
            // 
            // bHSil
            // 
            this.bHSil.Location = new System.Drawing.Point(542, 217);
            this.bHSil.Name = "bHSil";
            this.bHSil.Size = new System.Drawing.Size(75, 23);
            this.bHSil.TabIndex = 2;
            this.bHSil.Text = "sil";
            this.bHSil.UseVisualStyleBackColor = true;
            this.bHSil.Click += new System.EventHandler(this.bHSil_Click);
            // 
            // bhAra
            // 
            this.bhAra.Location = new System.Drawing.Point(542, 241);
            this.bhAra.Name = "bhAra";
            this.bhAra.Size = new System.Drawing.Size(75, 23);
            this.bhAra.TabIndex = 3;
            this.bhAra.Text = "arama";
            this.bhAra.UseVisualStyleBackColor = true;
            this.bhAra.Click += new System.EventHandler(this.bhAra_Click);
            // 
            // bHGüncel
            // 
            this.bHGüncel.Location = new System.Drawing.Point(542, 270);
            this.bHGüncel.Name = "bHGüncel";
            this.bHGüncel.Size = new System.Drawing.Size(75, 23);
            this.bHGüncel.TabIndex = 4;
            this.bHGüncel.Text = "Güncelle";
            this.bHGüncel.UseVisualStyleBackColor = true;
            this.bHGüncel.Click += new System.EventHandler(this.bHGüncel_Click);
            // 
            // hAdl
            // 
            this.hAdl.AutoSize = true;
            this.hAdl.Location = new System.Drawing.Point(465, 33);
            this.hAdl.Name = "hAdl";
            this.hAdl.Size = new System.Drawing.Size(74, 16);
            this.hAdl.TabIndex = 5;
            this.hAdl.Text = "hayvan Adı";
            // 
            // hAd
            // 
            this.hAd.Location = new System.Drawing.Point(542, 30);
            this.hAd.Name = "hAd";
            this.hAd.Size = new System.Drawing.Size(100, 22);
            this.hAd.TabIndex = 7;
            // 
            // hYas
            // 
            this.hYas.AutoSize = true;
            this.hYas.Location = new System.Drawing.Point(465, 67);
            this.hYas.Name = "hYas";
            this.hYas.Size = new System.Drawing.Size(76, 16);
            this.hYas.TabIndex = 8;
            this.hYas.Text = "hayvan yas";
            // 
            // cinsiyetT
            // 
            this.cinsiyetT.Location = new System.Drawing.Point(542, 92);
            this.cinsiyetT.Name = "cinsiyetT";
            this.cinsiyetT.Size = new System.Drawing.Size(100, 22);
            this.cinsiyetT.TabIndex = 11;
            // 
            // cinsiyet
            // 
            this.cinsiyet.AutoSize = true;
            this.cinsiyet.Location = new System.Drawing.Point(465, 95);
            this.cinsiyet.Name = "cinsiyet";
            this.cinsiyet.Size = new System.Drawing.Size(52, 16);
            this.cinsiyet.TabIndex = 10;
            this.cinsiyet.Text = "cinsiyet";
            // 
            // hid
            // 
            this.hid.AutoSize = true;
            this.hid.Location = new System.Drawing.Point(473, 2);
            this.hid.Name = "hid";
            this.hid.Size = new System.Drawing.Size(65, 16);
            this.hid.TabIndex = 12;
            this.hid.Text = "hayvan id";
            // 
            // hyasN
            // 
            this.hyasN.Location = new System.Drawing.Point(542, 61);
            this.hyasN.Name = "hyasN";
            this.hyasN.Size = new System.Drawing.Size(100, 22);
            this.hyasN.TabIndex = 14;
            // 
            // turid
            // 
            this.turid.AutoSize = true;
            this.turid.Location = new System.Drawing.Point(473, 126);
            this.turid.Name = "turid";
            this.turid.Size = new System.Drawing.Size(32, 16);
            this.turid.TabIndex = 15;
            this.turid.Text = "turid";
            this.turid.Click += new System.EventHandler(this.label1_Click);
            // 
            // turidN
            // 
            this.turidN.Location = new System.Drawing.Point(542, 126);
            this.turidN.Name = "turidN";
            this.turidN.Size = new System.Drawing.Size(100, 22);
            this.turidN.TabIndex = 16;
            // 
            // hidN
            // 
            this.hidN.Location = new System.Drawing.Point(545, 0);
            this.hidN.Name = "hidN";
            this.hidN.Size = new System.Drawing.Size(97, 22);
            this.hidN.TabIndex = 17;
            // 
            // hliste
            // 
            this.hliste.Location = new System.Drawing.Point(542, 299);
            this.hliste.Name = "hliste";
            this.hliste.Size = new System.Drawing.Size(75, 23);
            this.hliste.TabIndex = 18;
            this.hliste.Text = "listele";
            this.hliste.UseVisualStyleBackColor = true;
            this.hliste.Click += new System.EventHandler(this.hliste_Click);
            // 
            // hsayısı
            // 
            this.hsayısı.Location = new System.Drawing.Point(374, 300);
            this.hsayısı.Name = "hsayısı";
            this.hsayısı.Size = new System.Drawing.Size(143, 23);
            this.hsayısı.TabIndex = 19;
            this.hsayısı.Text = "hayvan sayısı";
            this.hsayısı.UseVisualStyleBackColor = true;
            this.hsayısı.Click += new System.EventHandler(this.hsayısı_Click);
            // 
            // beslenmeözeti
            // 
            this.beslenmeözeti.Location = new System.Drawing.Point(374, 329);
            this.beslenmeözeti.Name = "beslenmeözeti";
            this.beslenmeözeti.Size = new System.Drawing.Size(143, 23);
            this.beslenmeözeti.TabIndex = 20;
            this.beslenmeözeti.Text = "beslenme özeti";
            this.beslenmeözeti.UseVisualStyleBackColor = true;
            this.beslenmeözeti.Click += new System.EventHandler(this.beslenmeözeti_Click);
            // 
            // eksikMiftar
            // 
            this.eksikMiftar.Location = new System.Drawing.Point(374, 358);
            this.eksikMiftar.Name = "eksikMiftar";
            this.eksikMiftar.Size = new System.Drawing.Size(143, 23);
            this.eksikMiftar.TabIndex = 21;
            this.eksikMiftar.Text = "eksik stok mikterı";
            this.eksikMiftar.UseVisualStyleBackColor = true;
            this.eksikMiftar.Click += new System.EventHandler(this.eksikMiftar_Click);
            // 
            // toplamGelir
            // 
            this.toplamGelir.Location = new System.Drawing.Point(374, 387);
            this.toplamGelir.Name = "toplamGelir";
            this.toplamGelir.Size = new System.Drawing.Size(143, 23);
            this.toplamGelir.TabIndex = 22;
            this.toplamGelir.Text = "toplam gelir";
            this.toplamGelir.UseVisualStyleBackColor = true;
            this.toplamGelir.Click += new System.EventHandler(this.toplamGelir_Click);
            // 
            // alanid
            // 
            this.alanid.Location = new System.Drawing.Point(267, 301);
            this.alanid.Name = "alanid";
            this.alanid.Size = new System.Drawing.Size(101, 22);
            this.alanid.TabIndex = 23;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(202, 303);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(47, 16);
            this.label1.TabIndex = 24;
            this.label1.Text = "alan id";
            // 
            // id
            // 
            this.id.Location = new System.Drawing.Point(68, 329);
            this.id.Name = "id";
            this.id.Size = new System.Drawing.Size(37, 22);
            this.id.TabIndex = 26;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(-3, 332);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(65, 16);
            this.label2.TabIndex = 25;
            this.label2.Text = "hayvan id";
            // 
            // ilktarih
            // 
            this.ilktarih.Location = new System.Drawing.Point(140, 327);
            this.ilktarih.Name = "ilktarih";
            this.ilktarih.Size = new System.Drawing.Size(97, 22);
            this.ilktarih.TabIndex = 27;
            // 
            // sontarih
            // 
            this.sontarih.Location = new System.Drawing.Point(278, 327);
            this.sontarih.Name = "sontarih";
            this.sontarih.Size = new System.Drawing.Size(90, 22);
            this.sontarih.TabIndex = 28;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(111, 331);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(23, 16);
            this.label3.TabIndex = 29;
            this.label3.Text = "ilk ";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(243, 331);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(29, 16);
            this.label4.TabIndex = 30;
            this.label4.Text = "son";
            // 
            // tarih
            // 
            this.tarih.Location = new System.Drawing.Point(168, 385);
            this.tarih.Name = "tarih";
            this.tarih.Size = new System.Drawing.Size(200, 22);
            this.tarih.TabIndex = 31;
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(130, 387);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(32, 16);
            this.label5.TabIndex = 32;
            this.label5.Text = "tarih";
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(542, 332);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(75, 23);
            this.button1.TabIndex = 33;
            this.button1.Text = "çıkış";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // hayvanlar
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(800, 450);
            this.Controls.Add(this.button1);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.tarih);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.sontarih);
            this.Controls.Add(this.ilktarih);
            this.Controls.Add(this.id);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.alanid);
            this.Controls.Add(this.toplamGelir);
            this.Controls.Add(this.eksikMiftar);
            this.Controls.Add(this.beslenmeözeti);
            this.Controls.Add(this.hsayısı);
            this.Controls.Add(this.hliste);
            this.Controls.Add(this.hidN);
            this.Controls.Add(this.turidN);
            this.Controls.Add(this.turid);
            this.Controls.Add(this.hyasN);
            this.Controls.Add(this.hid);
            this.Controls.Add(this.cinsiyetT);
            this.Controls.Add(this.cinsiyet);
            this.Controls.Add(this.hYas);
            this.Controls.Add(this.hAd);
            this.Controls.Add(this.hAdl);
            this.Controls.Add(this.bHGüncel);
            this.Controls.Add(this.bhAra);
            this.Controls.Add(this.bHSil);
            this.Controls.Add(this.bHEkle);
            this.Controls.Add(this.dataGridView1);
            this.Name = "hayvanlar";
            this.Text = "hayvanlar";
            this.Load += new System.EventHandler(this.hayvanlar_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.hyasN)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.turidN)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.hidN)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.alanid)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.id)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.DataGridView dataGridView1;
        private System.Windows.Forms.Button bHEkle;
        private System.Windows.Forms.Button bHSil;
        private System.Windows.Forms.Button bhAra;
        private System.Windows.Forms.Button bHGüncel;
        private System.Windows.Forms.Label hAdl;
        private System.Windows.Forms.TextBox hAd;
        private System.Windows.Forms.Label hYas;
        private System.Windows.Forms.TextBox cinsiyetT;
        private System.Windows.Forms.Label cinsiyet;
        private System.Windows.Forms.Label hid;
        private System.Windows.Forms.NumericUpDown hyasN;
        private System.Windows.Forms.Label turid;
        private System.Windows.Forms.NumericUpDown turidN;
        private System.Windows.Forms.NumericUpDown hidN;
        private System.Windows.Forms.Button hliste;
        private System.Windows.Forms.Button hsayısı;
        private System.Windows.Forms.Button beslenmeözeti;
        private System.Windows.Forms.Button eksikMiftar;
        private System.Windows.Forms.Button toplamGelir;
        private System.Windows.Forms.NumericUpDown alanid;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.NumericUpDown id;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.DateTimePicker ilktarih;
        private System.Windows.Forms.DateTimePicker sontarih;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.DateTimePicker tarih;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Button button1;
    }
}

