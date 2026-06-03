import {
  HiOutlineSearch,
  HiOutlineLockClosed,
  HiOutlineSun,
  HiOutlineMoon,
  HiOutlineLocationMarker,
  HiOutlinePhone,
  HiOutlineExternalLink,
  HiOutlinePlay,
  HiStar,
} from 'react-icons/hi';
import {
  MdChair,
  MdInventory2,
  MdMedicalServices,
  MdScanner,
  MdRecycling,
  MdCamera,
  MdSchool,
  MdLocalHospital,
  MdScience,
  MdStorefront,
  MdBuild,
  MdBarChart,
  MdForum,
  MdPeople,
  MdAttachMoney,
  MdHandshake,
  MdDashboard,
  MdAdminPanelSettings,
  MdVideoLibrary,
  MdMap,
  MdDirections,
} from 'react-icons/md';
import { FaTooth } from 'react-icons/fa';

const ICON_MAP = {
  search: HiOutlineSearch,
  lock: HiOutlineLockClosed,
  sun: HiOutlineSun,
  moon: HiOutlineMoon,
  location: HiOutlineLocationMarker,
  phone: HiOutlinePhone,
  external: HiOutlineExternalLink,
  play: HiOutlinePlay,
  star: HiStar,
  tooth: FaTooth,
  chair: MdChair,
  box: MdInventory2,
  implant: MdMedicalServices,
  scan: MdScanner,
  recycle: MdRecycling,
  camera: MdCamera,
  course: MdSchool,
  clinic: MdLocalHospital,
  default: MdScience,
  unit: MdChair,
  scanner: MdScanner,
  composite: MdMedicalServices,
  used: MdRecycling,
  itero: MdCamera,
  marketplace: MdStorefront,
  technicians: MdBuild,
  clinics: MdLocalHospital,
  academy: MdSchool,
  dashboard: MdBarChart,
  forum: MdForum,
  patients: MdPeople,
  reports: MdAttachMoney,
  partnerships: MdHandshake,
  overview: MdDashboard,
  admin: MdAdminPanelSettings,
  video: MdVideoLibrary,
  map: MdMap,
  directions: MdDirections,
};

export default function AppIcon({ name = 'default', size = 24, className = '', title }) {
  const Icon = ICON_MAP[name] || ICON_MAP.default;
  return (
    <Icon
      size={size}
      className={`app-icon${className ? ` ${className}` : ''}`}
      aria-hidden={!title}
      title={title}
      role={title ? 'img' : undefined}
    />
  );
}

export { ICON_MAP };
