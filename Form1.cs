using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Npgsql;
using NpgsqlTypes;

namespace hayvanatBahçesi
{
    public partial class hayvanlar : Form
    {
        public hayvanlar()
        {
            InitializeComponent();
        }
        NpgsqlConnection baglanti = new NpgsqlConnection("server=localhost;port=5432;Database=hayvanatBahçesi;user Id=postgres;password=rky099.");
        private void hayvanlar_Load(object sender, EventArgs e)
        {

        }


        private void bHEkle_Click(object sender, EventArgs e)
        {
            baglanti.Open();
            NpgsqlCommand komut1 = new NpgsqlCommand("insert into \"Hayvanlar\"(ad,cinsiyet,yas,\"turId\") values(@p1,@p2,@p3,@p4)",baglanti);
            komut1.Parameters.AddWithValue("@p1",hAd.Text);
            komut1.Parameters.AddWithValue("@p2", cinsiyetT.Text);
            komut1.Parameters.AddWithValue("@p3", (int)hyasN.Value);
            komut1.Parameters.AddWithValue("@p4", (int)turidN.Value);
            komut1.ExecuteNonQuery();
            baglanti.Close();
            MessageBox.Show("eklendi");
        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void bHSil_Click(object sender, EventArgs e)
        {
            baglanti.Open();
            NpgsqlCommand komut2 = new NpgsqlCommand("DELETE from \"Hayvanlar\" where \"hayvanId\"=@p1", baglanti);
            komut2.Parameters.AddWithValue("@p1", (int)hidN.Value);
            komut2.ExecuteNonQuery();
            baglanti.Close();
            MessageBox.Show("silindi");
        }

        private void bHGüncel_Click(object sender, EventArgs e)
        {
            baglanti.Open();
            NpgsqlCommand komut3 = new NpgsqlCommand("update \"Hayvanlar\" set ad=@p1,yas=@p2,cinsiyet=@p3 where \"hayvanId\"=@p4",baglanti);
            komut3.Parameters.AddWithValue("@p1",hAd.Text);
            komut3.Parameters.AddWithValue("@p3", cinsiyetT.Text);
            komut3.Parameters.AddWithValue("@p2", (int)hyasN.Value);
            komut3.Parameters.AddWithValue("@p4", (int)hidN.Value);
            komut3.ExecuteNonQuery();
            baglanti.Close();
        }

        private void bhAra_Click(object sender, EventArgs e)
        {
            baglanti.Open();
            dataGridView1.DataSource = null;
            try
            {
                NpgsqlCommand komut4 = new NpgsqlCommand("SELECT \"hayvanId\", ad, yas, cinsiyet, \"turId\" FROM \"Hayvanlar\" WHERE \"hayvanId\" = @p1", baglanti);
                komut4.Parameters.AddWithValue("@p1", (int)hidN.Value);
                DataTable dt = new DataTable();
                NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut4);
                if (da.Fill(dt) > 0)
                {
                    dataGridView1.DataSource = dt;
                    MessageBox.Show("kayıt bulundu");
                }
                else
                {
                    MessageBox.Show("kayıt bulunamadı");
                }

            }
            catch (Exception ex)
            {
                MessageBox.Show("aramada hata oluştu");
            }
            baglanti.Close();
        }

        private void hliste_Click(object sender, EventArgs e)
        {
            string sorgu = "select * from \"Hayvanlar\"";
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
            DataSet ds =new DataSet();
            da.Fill(ds);    
            dataGridView1.DataSource = ds.Tables[0];
        }

        private void hsayısı_Click(object sender, EventArgs e)
        {
            baglanti.Open();
            dataGridView1.DataSource=null;  
            NpgsqlCommand komut5 = new NpgsqlCommand("select * from alanraporu(@alan)",baglanti);
            komut5.Parameters.AddWithValue("@alan", (int)alanid.Value);
            DataTable dt = new DataTable();
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut5);
            da.Fill(dt);
            dataGridView1.DataSource = dt;
            MessageBox.Show("yüklendi");
            baglanti.Close() ;

        }

        private void eksikMiftar_Click(object sender, EventArgs e)
        {
            baglanti.Open();
            dataGridView1.DataSource = null;
            NpgsqlCommand komut6 = new NpgsqlCommand("select * from eksikstokraporu()", baglanti);
            DataTable dt = new DataTable();
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut6);
            da.Fill(dt);
            dataGridView1.DataSource = dt;
            MessageBox.Show("yüklendi");
            baglanti.Close();
        }

        private void toplamGelir_Click(object sender, EventArgs e)
        {
            baglanti.Open();
            dataGridView1.DataSource = null;
            DateTime secilenTarih= tarih.Value.Date;
            NpgsqlCommand komut7 = new NpgsqlCommand("select * from toplamgelir(@tarih)", baglanti);
            komut7.Parameters.Add("@tarih", NpgsqlDbType.Date).Value=secilenTarih;
            DataTable dt = new DataTable();
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut7);
            da.Fill(dt);
            dataGridView1.DataSource = dt;
            MessageBox.Show("yüklendi");
            baglanti.Close();
        }

        private void beslenmeözeti_Click(object sender, EventArgs e)
        {
            baglanti.Open();
            dataGridView1.DataSource = null;
            DateTime ilkt= ilktarih.Value.Date;
            DateTime sont = sontarih.Value.Date;
            NpgsqlCommand komut8 = new NpgsqlCommand("select * from \"BeslenmeOzeti\"(@id,@ilk,@son)", baglanti);
            komut8.Parameters.AddWithValue("@id", (int)id.Value);
            komut8.Parameters.Add("@ilk", NpgsqlDbType.Date).Value = ilkt;
            komut8.Parameters.Add("@son", NpgsqlDbType.Date).Value = sont;
            DataTable dt = new DataTable();
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut8);
            da.Fill(dt);
            dataGridView1.DataSource = dt;
            MessageBox.Show("yüklendi");
            baglanti.Close();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}
