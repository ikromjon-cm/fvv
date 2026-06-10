export const cn = (...classes) => classes.filter(Boolean).join(' ');

export const formatDate = (date) => {
  return new Date(date).toLocaleDateString('uz-UZ', {
    year: 'numeric', month: 'long', day: 'numeric'
  });
};

export const getStatusColor = (status) => {
  const colors = {
    open: 'bg-emerald-100 text-emerald-700 dark:bg-emerald-500/20 dark:text-emerald-400',
    coming_soon: 'bg-amber-100 text-amber-700 dark:bg-amber-500/20 dark:text-amber-400',
    closed: 'bg-red-100 text-red-700 dark:bg-red-500/20 dark:text-red-400',
    active: 'bg-blue-100 text-blue-700 dark:bg-blue-500/20 dark:text-blue-400',
    completed: 'bg-green-100 text-green-700 dark:bg-green-500/20 dark:text-green-400',
  };
  return colors[status] || 'bg-gray-100 text-gray-700 dark:bg-gray-500/20 dark:text-gray-400';
};

export const getCertColor = (type) => {
  const colors = {
    gold: 'from-yellow-400 to-amber-500',
    silver: 'from-gray-300 to-gray-400',
    bronze: 'from-orange-400 to-amber-600',
    honorable: 'from-indigo-400 to-purple-500',
  };
  return colors[type] || 'from-indigo-400 to-purple-500';
};

export const getStatusLabel = (status) => {
  const labels = {
    open: "Ro'yxat ochiq",
    coming_soon: "Tez kunda",
    closed: "Yopilgan",
    active: "Faol",
    completed: "Yakunlangan",
  };
  return labels[status] || status;
};
