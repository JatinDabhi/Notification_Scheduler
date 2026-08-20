const AppModel = require('../models/AppModel');
const { getFirebaseApp } = require('./firebase');

// અહીંયા તમે તમારી બધી apps ઉમેરી કે કાઢી શકો છો. એક જ જગ્યાએથી બધું મેનેજ થશે.
const FIREBASE_APPS = [
  {
    appId: "dwarkadhish-wallpaper-9e560",
    appName: "Dwarkadhish Wallpaper",
    firebaseKeyJson: {
      "type": "service_account",
      "project_id": "dwarkadhish-wallpaper-9e560",
      "private_key_id": "d0a7607c99afcfc0e46d751f38508c386cafa511",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC+Uq/q2Njy0tJs\nzyiGByeUAhPmlU5Pp/R6O3jrPzEJQqqpXpWjqiqyuQtBYe/3YiBNEAA7kjq9OwoV\nxnSk6NzGja/xEBpzGyy7jf0/vDWxNtQqiRPuepnR7uDClRH15oMGK1IdD8QI4MBR\nrIL9ZCwmkrfFu7P3pleX8lipDzuE7Omozs0HS8t1SVbfBsjICfQLAZt0kgcTSUy/\n5uQSW759H5rYbQtBA+NyWzcI2ByOOG/0FMDCEVHMuwes9xJJ/4iq6QGb5ewbR+kI\nPXYp7tAndxpggXCXCnvWy/Dj/i70VdX63p/TvbwSlqETVtLBKLbXqlawbCVMrAcK\nT5K9maEhAgMBAAECggEAM7WnkjkkiKT7AxEtw2yCNlZyLb33LvFFHUi3S8M5gXiZ\ngbbvFS6Qt0pLYpJHboE8oXNtfMH4L52w2cW3v259PX0VhnuHlCqX9sVXP0/VjraE\n4qGnxq2MyVsLuhJidNsSUkTG5Jp5+qeF2Srz1AC5dil6wMCE3w5U0jXIHPbEhxKW\nfaGoWqg1qMfgm/5FtJkM+VYsOH25LfgzRNefN6xcMKSo2fRDqo4jeAwwbUX5w8/n\nTmDjOWveNJXSs5DnpMaPRfjA6z7VwbhE3FamG/eKw/bCfd9tkbWyXkQvVLEljEPz\nLVUO/ItX5uhxvHSwCO6HX7DZ3Yv+cpxcn5gNhnzcGQKBgQD5L2ToYwEppG6GWP2O\nU48IUvLs1hpqYajZQ7DZIlVO8IwLBBcs2IdPZds9bgpTG1xELJyFuP9rL57YyHKo\nENc5Uh9idBAs2W8B9nCOKvUFrx488hJaP3ndmCH+W2Fays3EFy5KrZLYPhW6cAT1\nXyQpWfH7taUA6c3Kmrp1m5Yq8wKBgQDDhy9SGuUnR4B6Jbmco3uPPUnda+r6sj1R\nKpCPgVsPz7v/ao+Vj8SUMJ7K+Q4Jt7tCjG8mYqcczyRqy/d48zlU8j/KDp70pWT8\nSBEiRbAN4J4DO/igmvnFjXFdV+y0dGLmBUU/L7ztSWKOSqn9ZFa6blVU73q97P4M\npZLMH8PgmwKBgQCnQVWU2edM4S7ChHbkkld+OdcOewNOBnEEK/hHNlFWZAVL25oG\nouvnsjF/QR4y/DlpFRyWcT8X3eXcEmdLQcqEkge42LiGsgddpOGVu2WtRAai18TT\nyKluwI+IoCNvgpKsnPaYb3sSJFIHSus5G3w1OUdAMYMoYsabyFGBYUZhWwKBgQCD\nMgP4bX9w+bMlQobmqXNQy2jyn2TNzicCfTL+d2dolpSobxHk4tCeNnl16+MVdii6\nIIy8DtnepMbkufNVPq4rZ1iR9XmG4it+c8S7YFMfHKYpuWW8LgCGI7/7R/HVq3po\nqQSrvxZfiSwOGd8x3M+szDeJhB6xrYFRbw+u02mVHQKBgHwWJZxzXw3p260IPDzo\n7VAOVWeP9z0sHo1pVZ896f2u3bBPZStshUaIxO9qoQPFSz0KEJDnqfnlJVl+GTTT\nRamv6UHcRH7Hh7RXtpeOY3xfW1fvvpy+LaiCSWtwF9QfUEmm/20fNg0TXpblI6J9\nvwraOiYXpCoznCQdoPpOTTwQ\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-fbsvc@dwarkadhish-wallpaper-9e560.iam.gserviceaccount.com",
      "client_id": "114942064362044484430",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40dwarkadhish-wallpaper-9e560.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    }
  },
  {
    appId: "ramdevpir-wallpaper-e4e97",
    appName: "Ramdevpir Wallpaper",
    firebaseKeyJson: {
      "type": "service_account",
      "project_id": "ramdevpir-wallpaper-e4e97",
      "private_key_id": "051e85b961f1acd34124b5ef5deabf7805ee6e5c",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCidbCbXk4VRXTH\n1std/WcyQKoF9y0D0fLSSfrwau0sLjQ9HbMpKZIK9QugvazQwpNdUqY1HZgMzgOg\ndi9V6oF3DyEXQwbLZSVYOQCQW5kJ+GUbSSDYhsBgOHQ/2vP0Mp495+F5tt2WXv/Q\nCkcCWmRyIow4HtNm2IRnwasPAaiS0AAz0JzdpDTVIbzcRpdoG9s9kdfDAr2WbcoN\niWZnqvs5gsSAmmwqSZxaZx+MMe8dgUTyTySxf1BebfkfM0sNaMrk/Kwzskmz6zGv\nGXwSR1BcjKvcEHrJ3xDtGp4koaJ2aX+OqQ9POgetkZyy/bCMaJa/BULCwWB96GQo\nxYLXqDXHAgMBAAECggEAEdcZu0i/tgnyuTqcX5MYa4YlWv1Z8KL0EZAKjK85TKeQ\nQ1aJGk/p1+aGozK2ZmsPnWkaPm1PCWJFjK/zInIGSz7v6Srfn/iuAVeqeQUjXlsW\n2J25tn1punHzS3XYYgHTAG+qgjVeH7QJTzJpuizsqIn5sEoA+LjLJXe441omcGSr\n6SivaPdOf6zuBg9BEcAx95DKHqkMcN6Tlw82YWqft/wqGT4XsGU3pJADyZqYT2HX\nltK0nT579QnixpWTUJni1GBz2pYCEGNi7jqSUN9q6AFqZipKKq7DbZdVhAZVK7wG\n4gmNPbu1YteJgloJW2M9PU9Qt1bQkNYaY9zy86feiQKBgQDSXrYlLqGpnCX85V1e\nhvQRaNzps6ZCq6tY6S4Ndhxj1sA0lH4tQE7v+pjDQjgMbhDXL2Az4w6CT9DYOnRp\n0ff73jn/C+Zmobqdz+/ISbVo3EJPK3JihNS4+NLUoAwq2gSWdjPS6KrgoHsI0t3U\nKIRpXD40ck/oXHgzJM6Z7pPXSQKBgQDFsqY2YycPFe42v7xzhLniKIJh8N7pA0eC\nY6ObRfqp6JhJ7WtvhDspnc0UT/ZRz4BOb2VRYk5+yS2vQagu3CyAqmJFLfF8gVPr\nCnDtFCyU6FSpz7M33SOwpncLr3PZ9oA4F0lTQ0S3Lw+5Pzp18qWgcfDYYHqUMOBG\nMYNhkfdUjwKBgQDKcC3jlf4n04WS2b2B62gPINQFaMWDvuNCyhFxDsm/IbcQYh0R\nuqK7uHEs5Ro+i+RUzthK1iLuL5SPn6DK/C0hCPbSgkcTWGrW1nSuTo/t+pcszGhk\neeKipX9s8R8EVYy4pcK1IQTe6E+9a/3f3aWeJhAONDrFJcbdoHvYEYffUQKBgQC1\nsR1u6KtyAt6+dHK23CmV/1LsvlmvXvMuk3I+dw8LbpffgZL2l1lkQwHChEbGI2Ux\nMNG1/RpVDYGuCzKNdo5z5aORHstMePNuFVd5m8vpQqjks91rHxL4+9R26dYYYKKw\naj5ahn01ucvCnaiV096CWZVW1zxwy4ajHEg5uNPNYwKBgGyaMoluVRv36auTFKXv\nXCIIb1Vhav2onxsQZjSgKM0ldFvrSI4bTzEVQYHgKQT+3SZyP2J1yTfsCUtM/SQ3\nFaZPotRKCdDobAtJ6lvcLhSUDWpgkaUBzeqpgPX0PqmY+Ud7OsetzBdjMZbHeaWy\njwI2DEeXyPWshExATgH6emvh\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-fbsvc@ramdevpir-wallpaper-e4e97.iam.gserviceaccount.com",
      "client_id": "104269242595253349992",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40ramdevpir-wallpaper-e4e97.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    }
  },
  {
    appId: "khatushyam-wallpaper-77315",
    appName: "Khatushyam Wallpaper",
    firebaseKeyJson: {
      "type": "service_account",
      "project_id": "khatushyam-wallpaper-77315",
      "private_key_id": "067dc86a8b426da27303d152d6d46eca2f70b434",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDeXTjazvI23nM2\nJnz644BXvideJrRmXC6kc2a/ellmbGNgyHvZ8UBvLhJZnsjbBXB6QaqSGkrh9Wpp\nmE3ewBvlVu00mIwuxqadAhVmvIM/hS5ThzGSBX2+JHyaiUR9B7F6MXEe9pFaA8NO\nIZYg75wFHZxXVWnS5JCwtgUIjoqTY8NNk6WXXdNmWbfn9kfiTT3MHRyXRAvDHZxf\nvXCu+GQk2oEx0s/NAuQlzusxBlWEwgYmN5NCB6gCU+TF5LIMEKAE76kS09qBnrlo\niKcw12JnY7sXAAFNM9mtlqmoK1JWQdw1nM0GXkDhS1/YKcZ3OPiL10Hgh1bYCC14\nbHaWSP0BAgMBAAECggEADIdLF0T2r7G74w6rFwWvawIrPKpImsXR2PEplltB4zvz\nI3ZYSBDINRtu7D6+iVyWmETP4/h4RJ/rtXRf2s+PIs5RghegOlh19b2yz/2KFY+e\n6xTgbZ5Cle5/WMOoKLVAwiY7/ecdjGlO3T2WNFfbvgwLjX4h/sBjCJnQ0ckaNLCc\n4aZ0BT0QEL6iHTUr7CRM9/aS/VpVXwgHVex444cG8gsCMzORAoxhFo8rCUOVNEpj\nNEQPu07WMzH4vKglQqxNjtMzqzTPhO3HVDWx74DI3RAd/LrqIOlPI0qFBYLAWJcc\n6J9afH7UK90C2g+md0U1Gp4wAmD3OqM2t8AZpLz+mwKBgQDzm0bntGP+Oux9MXW3\ne1vWj18wQKhc6esoS/3ryV+eAZDg55UyRYZGGJCv0AGZaSAjZyGweDD391vPbgKq\ny84QYvXyVRo2sYLlKDK1O3hwo8pIcx46xRIMqNfaNkhybuapsZQXGgnT/cyAvIbI\nzgDdTyGdalADTu1T/2ZHgssXiwKBgQDprUjqsetbO2S2Kl31ou6xFv0nuWpOARGQ\n0U8UTi+9x1wNDcRGD9TUetXrNDBGrBMRHgx97DivRyuH3fmJbh4CHzOaxd9xkSL8\nov2BSLCfwe/URFo2BqnAxl9SVlfpwnDlyT3YJdoDHONQu/8GMa7F3qTAd2V+D+ul\nX7s+7d7vIwKBgQDVq02u7/eAxxgk2xwAWo/8CvcX8K58CKS9TKIkjRV0FrWHvziK\nxpZ2pxdJTi4I7D9HLi9LhLCW3nzF3R0zx90vXE2TR3fdnydLbk3DzqzeR5umnmpW\nbAJf3jyt5kz3KjThhKN6+9jA+2zDQhkKyj3R35WBZ/1UWYcq1OpWMO+H7wKBgDGZ\nxauDnpib79G3BoC4WAAhCBVhhw4NrgPWWfnOatXWtlRTAsF4ZM3BURz+0+x8ZAOz\nJCWqeZHDAptxY6FnTVlX9CU7MSWzEAEeO78whcUzbkvZQmjLW0b/FIauqzSEQGCW\nKdlyl2cnv5yIeyZ+b0Gy87ei4Fk02ekde+pspXCPAoGAD7cKGz0L6QsghjOyyrth\ngLKh7xuc/v/MeInDItF/qEvQdNYkOtW+ToHVswNCa86ibqXw5aOjKROdoieu57M7\nCoKIbOU95KzWhzi+qxKQxf4Nuom/Mu4nyYU3KbICrzZc0xTqLRqMtOrwmsL9CPWu\nxM347BN9KsIsTy89UUZfqfE=\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-fbsvc@khatushyam-wallpaper-77315.iam.gserviceaccount.com",
      "client_id": "114324886692110368318",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40khatushyam-wallpaper-77315.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    }
  }
];

const syncAppsFromConfig = async () => {
  try {
    let syncedCount = 0;
    
    // બધી apps ને MongoDB માં save કરીશું જેથી Flutter app એને વાંચી શકે
    for (const app of FIREBASE_APPS) {
      const cleanAppId = app.appId.trim().toLowerCase();
      
      await AppModel.findOneAndUpdate(
        { appId: cleanAppId },
        { 
          appName: app.appName,
          firebaseKeyJson: JSON.stringify(app.firebaseKeyJson)
        },
        { upsert: true, new: true }
      );
      
      // Initialize Firebase App
      await getFirebaseApp(cleanAppId);
      syncedCount++;
    }
    
    console.log(`🔄 Pre-configured Apps Synced: ${syncedCount} apps loaded from firebase-keys.js`);
    
  } catch (error) {
    console.error("❌ Failed to sync pre-configured apps:", error.message);
  }
};

module.exports = {
  FIREBASE_APPS,
  syncAppsFromConfig
};
