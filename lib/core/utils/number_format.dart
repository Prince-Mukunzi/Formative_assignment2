String formatXp(int xp) =>
    xp.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+$)'), (_) => ',');
