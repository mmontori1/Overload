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
using System.Collections.Concurrent;

namespace Overload
{
    class myApplicationContext : ApplicationContext
    {
        // data members
        private NotifyIcon trayIcon;
        private Game game;
        public Dictionary<String, Game> games;
        private FixedSizedQueue<int> pings = new FixedSizedQueue<int>(5);


        // constructor
        public myApplicationContext()
        {
            this.games = new Dictionary<string, Game>();
            loadGames();
            trayIcon = new NotifyIcon();
            this.game = games["League of Legends"]; // defaults to overwatch
        }

        public void loadGames()
        {
            Game Lol = new Game("League of Legends");
            Lol.addRegionIP("NA", "104.160.131.1");
            Lol.addRegionIP("EUW", "104.160.141.3");
            Lol.addRegionIP("EUNE", "104.160.142.3");
            Lol.addRegionIP("OCE", "104.160.156.1");
            Lol.addRegionIP("LAN", "104.160.136.3");
            this.games.Add(Lol.title, Lol);
            Game Overwatch = new Game("Overwatch");
            Overwatch.addRegionIP("US West", "24.105.62.129");
            Overwatch.addRegionIP("US Central", "24.105.62.129");
            Overwatch.addRegionIP("EU1", "185.60.114.159");
            Overwatch.addRegionIP("EU2", "185.60.112.157");
            Overwatch.addRegionIP("Korea", "211.234.110.1");
            Overwatch.addRegionIP("Taiwan", "203.66.81.98");
            this.games.Add(Overwatch.title, Overwatch);
        }

        // member functions
        public void Display()
        {
            trayIcon.MouseClick += new MouseEventHandler(mc);
            trayIcon.Icon = Resources.white_sub;
            trayIcon.Text = "Overload";
            trayIcon.Visible = true;
            trayIcon.ContextMenuStrip = CreateContextMenu();
        }

        // releases resources
        public void Dispose()
        {
            trayIcon.Dispose();
        }

        // Pings server every second for a minute
        public async Task Ping()
        {
            string address, title;
            if (game.Equals("Overwatch"))
            {
                address = "24.105.62.129";
                title = "Overwatch: ";
            }
            else {
                address = "104.160.131.1";
                title = "LoL: ";
            }
            
            PingReply reply;
            Ping pinger = new Ping();
            int iter = 60;
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
                        await Task.Delay(1000);
                        trayIcon.Text = "iter: " + i.ToString();
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
            item.Image = Resources.LoL;
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
            game = games["Overwatch"];
            Ping();
        }

        void League_Click(object sender, EventArgs e)
        {
            game = games["League of Legends"];
            Ping();
        }

        void Exit_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

    }

    public class FixedSizedQueue<T> : ConcurrentQueue<T>
    {
        private readonly object syncObject = new object();

        public int Size { get; private set; }

        public FixedSizedQueue(int size)
        {
            Size = size;
        }

        public new void Enqueue(T obj)
        {
            base.Enqueue(obj);
            lock (syncObject)
            {
                while (base.Count > Size)
                {
                    T outObj;
                    base.TryDequeue(out outObj);
                }
            }
        }
    }

    public class Game
    {
        public String title { get; set;}
        private Dictionary<String, String> regionsIP;

        public Game(String title)
        {
            this.title = title;
            this.regionsIP = new Dictionary<string, string>();
        }

        public void addRegionIP(String region, String ip)
        {
            this.regionsIP.Add(region, ip);
        }
    }
}
