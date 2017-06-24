using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;
using System.Windows.Forms;
using Overload.Properties;
using System.Net.NetworkInformation;
using System.Collections.Concurrent;
using System.Threading;


namespace Overload
{
    class myApplicationContext : ApplicationContext
    {
        // data members
        private NotifyIcon trayIcon;
        private bool isRunning = false;
        private Game curGame;
        private String curRegion;
        public Dictionary<String, Game> games;
        private FixedSizedQueue<long> pings = new FixedSizedQueue<long>(5);
        Thread childThread;
        bool isAboutLoaded;

        // constructor
        public myApplicationContext()
        {
            this.games = new Dictionary<string, Game>();
            loadGames();
            trayIcon = new NotifyIcon();
            this.curGame = games["League of Legends"]; // defaults to LoL
            this.curRegion = "NA";
            childThread = new Thread(() => Ping());
            isAboutLoaded = false;
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

        public void Ping()
        {
            //Console.WriteLine("THREAD CREATED");
            String address = curGame.regionsIP[curRegion];

            PingReply reply;
            Ping pinger = new Ping();

            try
            {
                for (int i = 0; i < 60; i++)
                {
                    reply = pinger.Send(address);
                    pings.Enqueue(reply.RoundtripTime);
                    long avgPing = (long)pings.Average();
                    trayIcon.Text = curGame.title + " " + curRegion + ": " + avgPing;
                    if (avgPing > 100)
                    {
                        trayIcon.Icon = Resources.red_sub;
                    }
                    else if (avgPing > 60)
                    {
                        trayIcon.Icon = Resources.yellow_sub;
                    }
                    else
                    {
                        trayIcon.Icon = Resources.green_sub;
                    }
                    Thread.Sleep(1000);
                }
            }

            catch (PingException)
            {
                trayIcon.Text = "error";
            }
        }

        public void new_Thread()
        {
            //Console.WriteLine("CREATING NEW THREAD... ");
            end_Thread();
            childThread = new Thread(() => Ping());
            childThread.Start();
        }

        public void end_Thread() {
            if (childThread.IsAlive)
            {
                childThread.Abort();
            }
        }

        // handles left mouse click
        void mc(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                if (isRunning)
                {
                }
                else
                {
                    new_Thread();
                }
            }
        }


        // ----------------------------------------------

        // create contextmenustrip
        public ContextMenuStrip CreateContextMenu()
        {
            ContextMenuStrip menu = new ContextMenuStrip();
            ToolStripMenuItem item, submenu;

            // Overwatch submenu
            submenu = new ToolStripMenuItem();
            submenu.Text = "Overwatch";

            item = new ToolStripMenuItem();
            item.Text = "US Central";
            item.Click += new EventHandler(OV_US_Central_Click);
            submenu.DropDownItems.Add(item);

            item = new ToolStripMenuItem();
            item.Text = "US West";
            item.Click += new EventHandler(OV_US_West_Click);
            submenu.DropDownItems.Add(item);

            item = new ToolStripMenuItem();
            item.Text = "EU1";
            item.Click += new EventHandler(OV_EU1_Click);
            submenu.DropDownItems.Add(item);

            item = new ToolStripMenuItem();
            item.Text = "EU2";
            item.Click += new EventHandler(OV_EU2_Click);
            submenu.DropDownItems.Add(item);

            item = new ToolStripMenuItem();
            item.Text = "Korea";
            item.Click += new EventHandler(OV_KOR_Click);
            submenu.DropDownItems.Add(item);

            item = new ToolStripMenuItem();
            item.Text = "Taiwan";
            item.Click += new EventHandler(OV_TAI_Click);
            submenu.DropDownItems.Add(item);

            menu.Items.Add(submenu);

            // League submenu
            submenu = new ToolStripMenuItem();
            submenu.Text = "League";

            item = new ToolStripMenuItem();
            item.Text = "NA";
            item.Click += new EventHandler(LE_NA_Click);
            submenu.DropDownItems.Add(item);

            item = new ToolStripMenuItem();
            item.Text = "EUW";
            item.Click += new EventHandler(LE_EUW_Click);
            submenu.DropDownItems.Add(item);

            item = new ToolStripMenuItem();
            item.Text = "EUNE";
            item.Click += new EventHandler(LE_EUNE_Click);
            submenu.DropDownItems.Add(item);

            item = new ToolStripMenuItem();
            item.Text = "OCE";
            item.Click += new EventHandler(LE_OCE_Click);
            submenu.DropDownItems.Add(item);

            item = new ToolStripMenuItem();
            item.Text = "LAN";
            item.Click += new EventHandler(LE_LAN_Click);
            submenu.DropDownItems.Add(item);

            menu.Items.Add(submenu);

            // About tab
            item = new ToolStripMenuItem();
            item.Text = "About";
            item.Click += new System.EventHandler(About_Click);
            menu.Items.Add(item);

            // Exit tab
            item = new ToolStripMenuItem();
            item.Text = "Exit";
            item.Click += new System.EventHandler(Exit_Click);
            menu.Items.Add(item);

            return menu;
        }


        // OVERWATCH SUBMENU
        void OV_US_Central_Click(object sender, EventArgs e)
        {
            curGame = games["Overwatch"];
            curRegion = "US Central";
            new_Thread();
        }

        void OV_US_West_Click(object sender, EventArgs e)
        {
            curGame = games["Overwatch"];
            curRegion = "US West";
            new_Thread();
        }

        void OV_EU1_Click(object sender, EventArgs e)
        {
            curGame = games["Overwatch"];
            curRegion = "EU1";
            new_Thread();
        }

        void OV_EU2_Click(object sender, EventArgs e)
        {
            curGame = games["Overwatch"];
            curRegion = "EU2";
            new_Thread();
        }

        void OV_KOR_Click(object sender, EventArgs e)
        {
            curGame = games["Overwatch"];
            curRegion = "Korea";
            new_Thread();
        }

        void OV_TAI_Click(object sender, EventArgs e)
        {
            curGame = games["Overwatch"];
            curRegion = "Taiwan";
            new_Thread();
        }


        // LEAGUE SUBMENU
        void LE_NA_Click(object sender, EventArgs e)
        {
            curGame = games["League of Legends"];
            curRegion = "NA";
            new_Thread();
        }

        void LE_EUW_Click(object sender, EventArgs e)
        {
            curGame = games["League of Legends"];
            curRegion = "EUW";
            new_Thread();
        }

        void LE_EUNE_Click(object sender, EventArgs e)
        {
            curGame = games["League of Legends"];
            curRegion = "EUNE";
            new_Thread();
        }

        void LE_OCE_Click(object sender, EventArgs e)
        {
            curGame = games["League of Legends"];
            curRegion = "OCE";
            new_Thread();
        }

        void LE_LAN_Click(object sender, EventArgs e)
        {
            curGame = games["League of Legends"];
            curRegion = "LAN";
            new_Thread();
        }

        void About_Click(object sender, EventArgs e)
        {
            if (!isAboutLoaded) {
                isAboutLoaded = true;
                new AboutBox1().ShowDialog();
                isAboutLoaded = false;
            }
        }

        void Exit_Click(object sender, EventArgs e)
        {
            end_Thread();
            Application.Exit();
        }

        // ----------------------------------------------

        // create region menustrip
        public ContextMenuStrip regionMenu()
        {
            ContextMenuStrip regionMenu = new ContextMenuStrip();
            ToolStripMenuItem item;

            if (curGame == games["Overwatch"]) {
                item = new ToolStripMenuItem();
                item.Text = "US Central";
                item.Click += new EventHandler(US_Central_Click);
                regionMenu.Items.Add(item);
            }
            else {
                item = new ToolStripMenuItem();
                item.Text = "NA";
                item.Click += new EventHandler(NA_Click);
                regionMenu.Items.Add(item);
            }
            return regionMenu;
        }

        void US_Central_Click(object sender, EventArgs e) {

        }

        void NA_Click(object sender, EventArgs e)
        {

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
        public String title { get; set; }
        public Dictionary<String, String> regionsIP { get; }

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