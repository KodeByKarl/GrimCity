export interface OfficerProfile {
  identifier: string;
  name: string;
  callsign: string;
  department: string;
  badge_number: string;
  rank: string;
  grade: number;
  job: string;
}

export interface PenalCodeItem {
  id?: number;
  code: string;
  title: string;
  category: string;
  class: 'Infraction' | 'Misdemeanor' | 'Felony';
  fine: number;
  jail_time: number;
  points?: number;
  description: string;
}

export interface Warrant {
  id: number;
  suspect_identifier: string;
  suspect_name: string;
  charges: PenalCodeItem[] | string[];
  reason: string;
  issuing_officer: string;
  issuing_officer_identifier?: string;
  status: 'Active' | 'Served' | 'Cancelled';
  expire_date?: string;
  created_at: string;
}

export interface Bolo {
  id: number;
  type: 'person' | 'vehicle' | 'area';
  title: string;
  target: string;
  description: string;
  priority: 'low' | 'medium' | 'high' | 'urgent';
  image_url?: string;
  author_name: string;
  author_identifier?: string;
  status: 'active' | 'resolved';
  created_at: string;
}

export interface CitizenNote {
  id: number;
  identifier: string;
  note: string;
  author_name: string;
  image_url?: string;
  created_at: string;
}

export interface CitizenProfile {
  identifier: string;
  firstname: string;
  lastname: string;
  dateofbirth: string;
  gender: string;
  height: string;
  job: string;
  phone: string;
  licenses: string[];
  vehicles: { plate: string; model: string; stored: boolean }[];
  warrants: Warrant[];
  notes: CitizenNote[];
  priors: IncidentReport[];
  mugshotUrl?: string;
}

export interface VehicleFlag {
  id: number;
  plate: string;
  flag_type: string;
  reason: string;
  author_name: string;
  created_at: string;
}

export interface VehicleRecord {
  plate: string;
  owner: string;
  ownerIdentifier: string;
  phone: string;
  model: string;
  color: string;
  stored: boolean;
  garage: string;
  flags: VehicleFlag[];
  bolos: Bolo[];
}

export interface IncidentReport {
  id?: number;
  title: string;
  description: string;
  location: string;
  reporting_officer: string;
  reporting_officer_identifier?: string;
  suspects: { name: string; identifier?: string; dob?: string }[];
  officers: { name: string; callsign?: string }[];
  charges: PenalCodeItem[];
  evidence: { type: string; description: string; imageUrl?: string }[];
  status: 'Draft' | 'Open' | 'Under Investigation' | 'Closed';
  total_fine: number;
  total_jail: number;
  created_at?: string;
  updated_at?: string;
}

export interface DutyOfficer {
  source: number;
  identifier: string;
  name: string;
  callsign: string;
  department: string;
  badge_number: string;
  rank: string;
  grade: number;
  job: string;
  status: string; // "10-8", "10-6", "10-97", "10-7", "10-99"
  radio: string;
  coords?: { x: number; y: number; z: number };
}

export interface DispatchUnit {
  source: number;
  callsign: string;
  name: string;
}

export interface DispatchCall {
  id: number;
  code: string;
  title: string;
  message: string;
  coords: { x: number; y: number; z: number };
  street: string;
  caller: string;
  phone: string;
  priority: 'low' | 'medium' | 'high' | 'urgent';
  units: DispatchUnit[];
  status: 'active' | 'resolved';
  time: string;
}

export interface MdtPermissions {
  view_mdt?: number;
  create_incident?: number;
  edit_incident?: number;
  delete_incident?: number;
  create_warrant?: number;
  delete_warrant?: number;
  create_bolo?: number;
  delete_bolo?: number;
  create_vehicle_flag?: number;
  delete_vehicle_flag?: number;
  edit_penal_codes?: number;
  manage_licenses?: number;
  send_announcement?: number;
}

export interface MdtInitialData {
  officer: OfficerProfile;
  warrants: Warrant[];
  bolos: Bolo[];
  penalCodes: PenalCodeItem[];
  recentIncidents: IncidentReport[];
  activeOfficers: DutyOfficer[];
  dispatchCalls: DispatchCall[];
  permissions: MdtPermissions;
}

export type MdtAppId = 
  | 'home'
  | 'dispatch'
  | 'map'
  | 'citizens'
  | 'vehicles'
  | 'warrants'
  | 'incidents'
  | 'penal'
  | 'roster'
  | 'settings';
