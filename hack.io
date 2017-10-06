#!/usr/bin/python3
import random
import math

class gamestate:
  script_kiddie = None
  service_list = None
  status = None
  def __init__(self):
    pass
  def save():
    pass
  def load():
    pass
    
class script:
  name = None
  type = None
  hits_msg = None
  miss_msg = None
  min_dmg = None
  max_dmg = None
  animation = None
  def __init__(self,name,type,min_dmg,max_dmg,hits_msg='%(script)s is successful',miss_msg='%(script)s failed',animation='',activity=None):  
    self.name = name
    self.min_dmg = min_dmg
    self.max_dmg = max_dmg
    self.hits_msg = hits_msg
    self.miss_msg = miss_msg
    self.animation = animation
    self.activity = activity
    self.type = type

  def use(self,script_kiddie,cur_target,cur_service):
    fmt_dict = {'kiddie':script_kiddie.name,'script':self.name,'target':cur_target.name,'service':cur_service.name}
    out = '%(kiddie)s used %(script)s against %(target)s => %(service)s' % fmt_dict
    print(out)
    if random.random() < script_kiddie.level / cur_target.difficulty:
      print(self.hits_msg % fmt_dict)
      if self.activity is None:
        damage = random.randrange(self.min_dmg, self.max_dmg + 1)
      else:
        damage = self.activity()
      if self.type == cur_service.weakness:
        print("%(script)s is very effective against %(service)s!" % fmt_dict)
        damage *= 10
      cur_service.health -= damage
      if cur_service.health < 1:
        cur_service.die()
        cur_target.services.pop()
    else:
      print(self.miss_msg % fmt_dict)


class service:
  name = None
  health = None
  max_health = None
  weakness = None
  def __init__(self,name,health,weakness):
    self.name = name
    self.health = health
    self.max_health = health
    self.weakness = weakness
  def die(self):
    print("%s HAS BEEN EXPLOITED" % self.name)        
  
class proxy:
  name = None
  health = None
  max_health = None
  def __init__(self,name,health):
    self.name = name
    self.health = health
    self.max_health = health
  def die(self):
    print("%s HAS BEEN TRACED!" % self.name)
  def heal(self, amount):
    if self.health + amount > self.max_health:
      self.health = self.max_health
    else:
      self.health += amount
    print("PATCH: %(name)s trace decreased to %(health)d%%" % {'name':self.name, 'health':100 - math.floor(self.health * 100 / self.max_health)}) 
  def tracing(self):
    print("TRACE: %(name)s %(pct)d%%" % {'name':self.name, 'pct':100 - math.floor(self.health * 100 / self.max_health)})

class target:
  name = None
  services = None
  difficulty = None
  def __init__(self,name,difficulty):
    self.name = name
    self.difficulty = difficulty
    self.services = [service(x.name,x.health,x.weakness) for x in random.sample(service_list,math.floor(difficulty))]
  def trace(self,proxy):
    proxy.health -= random.randrange(1,45) * self.difficulty
    if proxy.health > 0:
      proxy.tracing()
  def die(self):
    print("%s HAS BEEN PWNED!" % self.name)
   
class kiddie:
  name = None
  level = None
  proxies = None #array of defeated enemies
#  scripts = None #todo make darkweb a place to buy scripts
  def __init__(self,name):
    self.name = name
    self.level = 1
    self.proxies = [proxy('localhost',300)]
  def check_proxies(self):
    if len(self.proxies) > 0 and self.proxies[-1].health <= 0:
      self.proxies[-1].die()
      self.proxies = self.proxies[:len(self.proxies) - 1]
  def scan(self):
    return target(random_name(),random.randrange(max(self.level - 1,1), min(self.level + 2,len(service_list))))
  def hack(self,cur_target):
    traceback = False
    while len(self.proxies) > 0 and len(cur_target.services) > 0:
      #ask player what he wants to do
      print("TARGET: %(tgt)s => %(srv)s INTEGRITY: %(pct)d%%" % {'tgt':cur_target.name, 'srv':cur_target.services[-1].name, 'pct':math.floor(cur_target.services[-1].health * 100 / cur_target.services[-1].max_health)})
      action = select_option(['scripts','give up','patch proxy'])
      if action == 0: #scripts
        cur_script = select_option([x.name for x in script_list] + ['back'])
        if cur_script < len(script_list):
          script_list[cur_script].use(self, cur_target, cur_target.services[-1])
          traceback = True
      elif action == 1: #give up
        break
      elif action == 2: #patch proxies
        cur_proxy = select_option(['%(name)s %(pct)d%%' % {'name':x.name,'pct':100 - math.floor(x.health * 100 / x.max_health)} for x in self.proxies] + ['back'])
        if cur_proxy < len(self.proxies) and self.proxies[cur_proxy].health < self.proxies[cur_proxy].max_health:         
            amount = 100 * self.level
            self.proxies[cur_proxy].heal(amount)
            traceback = True
      self.check_proxies() #in case action failed and special event caused proxy loss
      if len(self.proxies) > 0 and traceback and len(cur_target.services) > 0:
        cur_target.trace(self.proxies[-1])
        traceback = False
      self.check_proxies()
    if len(self.proxies) > 0 and len(cur_target.services) == 0:
      self.proxies.append(proxy(cur_target.name,cur_target.difficulty * 100))
      print("PROXY: added %s as new proxy connection!" % cur_target.name)
  def anonymize(self):
    for x in self.proxies:
      if x.health < x.max_health:
        x.heal(self.level * 100)
    remote = self.proxies[1:]
    random.shuffle(remote)
    self.proxies = [self.proxies[0]] + remote
      
def select_option(option_list):
  c = ''
  while not (str.isdigit(c) and (int(c) in range(len(option_list)))):
    for i in range(len(option_list)):
      print('%(index)d) %(option)s' % {'index':i, 'option':option_list[i]})
    c = input('>')
  return int(c)

def random_name():
  type = random.choice(['domain','subdomain','ipv4','host'])
  if type == 'domain' or type == 'subdomain':
    out = ''.join(random.sample("abcdefghijklmnopqrstuvwxyz0123456789-_",random.randrange(5,10)))
    out += '.' + random.choice(['com','net','gov','biz','pizza','me'])
    if type == 'subdomain':
      out = ''.join(random.sample("abcdefghijklmnopqrstuvwxyz0123456789-_",random.randrange(5,10))) + '.' + out
  elif type == 'ipv4':
    out = str(random.randrange(0,256))
    out += '.' + str(random.randrange(0,256))
    out += '.' + str(random.randrange(0,256))
    out += '.' + str(random.randrange(0,256))
  else: #type == host
    out = random.choice(["\\\\",""])
    out += ''.join(random.sample("abcdefghijklmnopqrstuvwxyz0123456789-_",random.randrange(5,10)))
  return out


def init():
  state = gamestate()
  print("what's your name?")
  state.script_kiddie = kiddie(input(">"))
  global service_list
  service_list = [service('apache',100,'fuzzer'),service('mysql',200,'sql_injection'),service('IIS',200,'fuzzer')]
  global script_list
  script_list = [script('sully.py','fuzzer',10,50),script('bitch.exe','sql_injection',10,50),script('nasty.js','xss',10,50)]
  return state

def gameloop(state):
  player = state.script_kiddie
  while True:
    print("what's next?")
    action = select_option(["scan for targets","anonymize","exit"])
    if action == 0:
      while action == 0:
        cur_target = player.scan()
        print("****hmap v3.04*****")
        print("host %s" % cur_target.name)
        print("services:")
        for x in cur_target.services:
          print("  %(name)s port: %(port)d" % {'name':x.name, 'port':random.randrange(20,10000)})
        print("difficulty: %d" % cur_target.difficulty)
        action = select_option(["scan again","hack","back"])
      if action == 1:
        player.hack(cur_target)
        if len(player.proxies) == 0:
          print("GAME OVER")
          break
    elif action == 1:
      print("shuffling proxies")
      player.anonymize()
      #else: go back
    else:
      break

service_list = []
script_list = []
state = init()
gameloop(state)      
    

