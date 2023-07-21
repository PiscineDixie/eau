class User < ApplicationRecord
  
  Roles = %w(base admin su)
  
  validates_presence_of :courriel, :nom, :roles
  validates_uniqueness_of :courriel
  validates_inclusion_of :roles, :in => User::Roles
  
  def self.from_courriel(courriel)
    u = User.find_by(courriel: courriel);
    return u unless u.nil?;
    
    # on cherche dans la tables des employes
    e = Employe.find_by(courriel: courriel);
    return nil if e.nil? || !e.actif?
    u = User.new({nom: (e.prenom + " " + e.nom), roles: 'base', courriel: e.courriel});
    u.save!
    return u;
  end
    
  def self.hasAdminPriviledge(id)
    u = User.find_by_id(id)
    return u != nil && Roles.index(u.roles) > 0
  end
  
  def self.hasSuperUserPriviledge(id)
    u = User.find_by_id(id)
    return u != nil && User::Roles[2] == u.roles
  end
  
  def self.sessionUserId(id)
    return User.find_by_id(id).courriel
  end
  
  # Retourne true si l'usager avec le id donne a un role egal ou superieur au role fourni
  def self.isPeerOrSuperior(id, roleStr)
    user = User.find(id)
    if !Roles.index(roleStr)
      raise "Rôle invalide."
    end
    if !user
      raise "Usager courant ne peut être récupéré."
    end
    return Roles.index(user.roles) >= Roles.index(roleStr)
  end

  def self.empty?
    return User.count.zero?
  end
end
