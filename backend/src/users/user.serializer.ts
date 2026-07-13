import { Role, User } from '@prisma/client';

/**
 * JSON shape compatible with the Flutter apps' UserModel
 * (plus role/email fields the apps can ignore).
 */
export function toUserJson(u: User) {
  return {
    id: u.id,
    name: u.name,
    lastName: u.lastName,
    phone: u.phone ?? '',
    email: u.email ?? '',
    address: u.address,
    city: u.city,
    postalCode: u.postalCode,
    group: u.group,
    lat: u.lat,
    lng: u.lng,
    language: u.language,
    photoUrl: u.photoUrl,
    role: u.role,
    isAdmin: u.role === Role.ADMIN || u.role === Role.SUPERADMIN,
    isDriver: u.role === Role.DRIVER,
    isVerified: u.isVerified,
    isActive: u.isActive,
    referredBy: u.referredBy,
    createdAt: u.createdAt.toISOString(),
  };
}
