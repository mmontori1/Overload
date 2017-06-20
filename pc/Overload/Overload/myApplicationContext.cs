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
        private int game;

        // constructor
        public myApplicationContext()
        {
            trayIcon = new NotifyIcon();
            game = 0; // defaults to overwatch
        }

        // member functions
        public void Display()
        {
            trayIcon.MouseClick += new MouseEventHandler(mc);
            trayIcon.Icon = Resources.submarine;
            trayIcon.Text = "Overload";
            trayIcon.Visible = true;
            trayIcon.ContextMenuStrip = CreateContextMenu();
        }

        // releases resources
        public void Dispose()
        {
            trayIcon.Dispose();
        }

        // Pings Overwatch US Central server every second for a minute
        public void Ping()
        {
            string address, title;
            if (game == 0)
            {
                address = "24.105.62.129";
                title = "OverWatch: ";
            }
            else {
                address = "104.160.131.1";
                title = "League: ";
            }
            
            PingReply reply;
            Ping pinger = new Ping();
            int iter = 1;
            int average = 0;
            int sum = 0;

            try
            {
                for (int i = 0; i < iter; i++)
                {
                    reply = pinger.Send(address);

                    if (reply.Status == IPStatus.Success)
                    {
                        sum += Convert.ToInt32(reply.RoundtripTime);
                    }
                }
            }
            catch (PingException)
            {
                trayIcon.Text = "error";
            }

            // calulate average ping
            average = sum / iter;
            trayIcon.Text = title + average.ToString();
        }

        // handles left mouse click
        void mc(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                Ping();
            }
        }


        // ----------------------------------------------

        // create contextmenustrip
        public ContextMenuStrip CreateContextMenu()
        {
            ContextMenuStrip menu = new ContextMenuStrip();
            ToolStripMenuItem item;

            item = new ToolStripMenuItem();
            item.Text = "Overwatch";
            item.Click += new EventHandler(Overwatch_Click);
            item.Image = Resources.overwatch;
            menu.Items.Add(item);

            item = new ToolStripMenuItem();
            item.Text = "League";
            item.Click += new EventHandler(League_Click);
            item.Image = Resources.league;
            menu.Items.Add(item);

            // Exit.
            item = new ToolStripMenuItem();
            item.Text = "Exit";
            item.Click += new System.EventHandler(Exit_Click);
            menu.Items.Add(item);

            return menu;
        }

        void Overwatch_Click(object sender, EventArgs e)
        {
            game = 0;
            Ping();
        }

        void League_Click(object sender, EventArgs e)
        {
            game = 1;
            Ping();
        }

        void Exit_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

    }
}
