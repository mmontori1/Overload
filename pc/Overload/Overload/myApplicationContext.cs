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

        // constructor
        public myApplicationContext()
        {
            this.games = new Dictionary<string, Game>();
            loadGames();
            trayIcon = new NotifyIcon();
            this.curGame = games["League of Legends"]; // defaults to LoL
            this.curRegion = "NA";
            childThread = new Thread(() => Ping());
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
            if (childThread.IsAlive)
            {
                childThread.Abort();
                //Console.WriteLine("THREAD ENDED");
            }
            childThread = new Thread(() => Ping());
            childThread.Start();
        }

        public void end_Thread() {
            if (childThread.IsAlive)
            {
                childThread.Abort();
            }
        }

        // releases resources
        public void Dispose()
        {
            trayIcon.Dispose();
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
            curGame = games["Overwatch"];
            curRegion = "US Central"; // default until we can handle region changes
            new_Thread();
        }

        void League_Click(object sender, EventArgs e)
        {
            curGame = games["League of Legends"];
            curRegion = "NA"; // default until we can handle region changes
            new_Thread();
        }

        void Exit_Click(object sender, EventArgs e)
        {
            end_Thread();
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