using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;
using System.Windows.Forms;
using Overload.Properties;
using System.Net.NetworkInformation;
using System.Reflection;
using System.IO;

namespace Overload
{
    class myApplicationContext : ApplicationContext
    {
        // data members
        private NotifyIcon trayIcon;

        // constructor
        public myApplicationContext()
        {
            trayIcon = new NotifyIcon();
        }

        // member functions
        public void Display()
        {
            trayIcon.MouseClick += new MouseEventHandler(mc);
            trayIcon.Icon = Resources.submarine;
            trayIcon.Text = "Ping Pong";
            trayIcon.Visible = true;
            Ping();
        }

        // releases resources
        public void Dispose()
        {
            trayIcon.Dispose();
        }

        // Pings Overwatch US Central server every second for a minute
        public void Ping()
        {

            string address = "24.105.62.129";
            PingReply reply;
            Ping pinger = new Ping();
            int iter = 60;

            try
            {
                for (int i = 0; i < iter; i++)
                {
                    reply = pinger.Send(address);

                    if (reply.Status == IPStatus.Success)
                    {
                        trayIcon.Text = reply.RoundtripTime.ToString();
                    }
                    System.Threading.Thread.Sleep(1000 - Convert.ToInt32(reply.RoundtripTime));
                }
            }
            catch (PingException)
            {
                trayIcon.Text = "error";
            }
        }

        // handles left mouse click
        void mc(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                Ping();
            }
            if (e.Button == MouseButtons.Right)
            {
                Application.Exit();
            }
        }
    }
}
