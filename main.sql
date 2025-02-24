create database shoes;
use shoes;

CREATE TABLE IF NOT EXISTS `__EFMigrationsHistory` (
    `MigrationId` varchar(150) NOT NULL,
    `ProductVersion` varchar(32) NOT NULL,
    PRIMARY KEY (`MigrationId`)
);

START TRANSACTION;

CREATE TABLE `Categories` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `Name` longtext NOT NULL,
    `Description` longtext NULL,
    PRIMARY KEY (`Id`)
);

CREATE TABLE `Products` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `Name` longtext NOT NULL,
    `Price` decimal(18,2) NOT NULL,
    `Description` longtext NULL,
    `ImageUrl` longtext NULL,
    PRIMARY KEY (`Id`)
);

CREATE TABLE `Roles` (
    `Id` varchar(255) NOT NULL,
    `Name` varchar(256) NULL,
    `NormalizedName` varchar(256) NULL,
    `ConcurrencyStamp` longtext NULL,
    PRIMARY KEY (`Id`)
);

CREATE TABLE `Users` (
    `Id` varchar(255) NOT NULL,
    `Discriminator` varchar(13) NOT NULL,
    `HomeAddress` longtext NULL,
    `RefreshToken` longtext NULL,
    `RefreshTokenExpiryTime` datetime(6) NULL,
    `TotalPurchase` decimal(18,2) NULL,
    `UserName` varchar(256) NULL,
    `NormalizedUserName` varchar(256) NULL,
    `Email` varchar(256) NULL,
    `NormalizedEmail` varchar(256) NULL,
    `EmailConfirmed` tinyint(1) NOT NULL,
    `PasswordHash` longtext NULL,
    `SecurityStamp` longtext NULL,
    `ConcurrencyStamp` longtext NULL,
    `PhoneNumber` longtext NULL,
    `PhoneNumberConfirmed` tinyint(1) NOT NULL,
    `TwoFactorEnabled` tinyint(1) NOT NULL,
    `LockoutEnd` datetime NULL,
    `LockoutEnabled` tinyint(1) NOT NULL,
    `AccessFailedCount` int NOT NULL,
    PRIMARY KEY (`Id`)
);

CREATE TABLE `ProductDetails` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `ProductId` int NOT NULL,
    `Size` int NOT NULL,
    `Color` longtext NOT NULL,
    `StockQuantity` int NOT NULL,
    PRIMARY KEY (`Id`),
    CONSTRAINT `FK_ProductDetails_Products_ProductId` FOREIGN KEY (`ProductId`) REFERENCES `Products` (`Id`) ON DELETE CASCADE
);

CREATE TABLE `ProductsCategories` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `ProductId` int NOT NULL,
    `CategoryId` int NOT NULL,
    PRIMARY KEY (`Id`),
    CONSTRAINT `FK_ProductsCategories_Categories_CategoryId` FOREIGN KEY (`CategoryId`) REFERENCES `Categories` (`Id`) ON DELETE CASCADE,
    CONSTRAINT `FK_ProductsCategories_Products_ProductId` FOREIGN KEY (`ProductId`) REFERENCES `Products` (`Id`) ON DELETE CASCADE
);

CREATE TABLE `RoleClaims` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `RoleId` varchar(255) NOT NULL,
    `ClaimType` longtext NULL,
    `ClaimValue` longtext NULL,
    PRIMARY KEY (`Id`),
    CONSTRAINT `FK_RoleClaims_Roles_RoleId` FOREIGN KEY (`RoleId`) REFERENCES `Roles` (`Id`) ON DELETE CASCADE
);

CREATE TABLE `Orders` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `UserId` varchar(255) NOT NULL,
    `TotalPrice` decimal(18,2) NOT NULL,
    `OrderDate` datetime(6) NOT NULL,
    `ShippingAddress` longtext NOT NULL,
    PRIMARY KEY (`Id`),
    CONSTRAINT `FK_Orders_Users_UserId` FOREIGN KEY (`UserId`) REFERENCES `Users` (`Id`) ON DELETE CASCADE
);

CREATE TABLE `UserClaims` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `UserId` varchar(255) NOT NULL,
    `ClaimType` longtext NULL,
    `ClaimValue` longtext NULL,
    PRIMARY KEY (`Id`),
    CONSTRAINT `FK_UserClaims_Users_UserId` FOREIGN KEY (`UserId`) REFERENCES `Users` (`Id`) ON DELETE CASCADE
);

CREATE TABLE `UserLogins` (
    `LoginProvider` varchar(255) NOT NULL,
    `ProviderKey` varchar(255) NOT NULL,
    `ProviderDisplayName` longtext NULL,
    `UserId` varchar(255) NOT NULL,
    PRIMARY KEY (`LoginProvider`, `ProviderKey`),
    CONSTRAINT `FK_UserLogins_Users_UserId` FOREIGN KEY (`UserId`) REFERENCES `Users` (`Id`) ON DELETE CASCADE
);

CREATE TABLE `UserRoles` (
    `UserId` varchar(255) NOT NULL,
    `RoleId` varchar(255) NOT NULL,
    PRIMARY KEY (`UserId`, `RoleId`),
    CONSTRAINT `FK_UserRoles_Roles_RoleId` FOREIGN KEY (`RoleId`) REFERENCES `Roles` (`Id`) ON DELETE CASCADE,
    CONSTRAINT `FK_UserRoles_Users_UserId` FOREIGN KEY (`UserId`) REFERENCES `Users` (`Id`) ON DELETE CASCADE
);

CREATE TABLE `UserTokens` (
    `UserId` varchar(255) NOT NULL,
    `LoginProvider` varchar(255) NOT NULL,
    `Name` varchar(255) NOT NULL,
    `Value` longtext NULL,
    PRIMARY KEY (`UserId`, `LoginProvider`, `Name`),
    CONSTRAINT `FK_UserTokens_Users_UserId` FOREIGN KEY (`UserId`) REFERENCES `Users` (`Id`) ON DELETE CASCADE
);

CREATE TABLE `OrderDetails` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `OrderId` int NOT NULL,
    `ProductDetailsId` int NOT NULL,
    `Quantity` int NOT NULL,
    PRIMARY KEY (`Id`),
    CONSTRAINT `FK_OrderDetails_Orders_OrderId` FOREIGN KEY (`OrderId`) REFERENCES `Orders` (`Id`) ON DELETE CASCADE,
    CONSTRAINT `FK_OrderDetails_ProductDetails_ProductDetailsId` FOREIGN KEY (`ProductDetailsId`) REFERENCES `ProductDetails` (`Id`) ON DELETE CASCADE
);

CREATE INDEX `IX_OrderDetails_OrderId` ON `OrderDetails` (`OrderId`);

CREATE INDEX `IX_OrderDetails_ProductDetailsId` ON `OrderDetails` (`ProductDetailsId`);

CREATE INDEX `IX_Orders_UserId` ON `Orders` (`UserId`);

CREATE INDEX `IX_ProductDetails_ProductId` ON `ProductDetails` (`ProductId`);

CREATE INDEX `IX_ProductsCategories_CategoryId` ON `ProductsCategories` (`CategoryId`);

CREATE INDEX `IX_ProductsCategories_ProductId` ON `ProductsCategories` (`ProductId`);

CREATE INDEX `IX_RoleClaims_RoleId` ON `RoleClaims` (`RoleId`);

CREATE UNIQUE INDEX `RoleNameIndex` ON `Roles` (`NormalizedName`);

CREATE INDEX `IX_UserClaims_UserId` ON `UserClaims` (`UserId`);

CREATE INDEX `IX_UserLogins_UserId` ON `UserLogins` (`UserId`);

CREATE INDEX `IX_UserRoles_RoleId` ON `UserRoles` (`RoleId`);

CREATE INDEX `EmailIndex` ON `Users` (`NormalizedEmail`);

CREATE UNIQUE INDEX `UserNameIndex` ON `Users` (`NormalizedUserName`);

INSERT INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`)
VALUES ('20250115095451_init database', '8.0.11');

COMMIT;

START TRANSACTION;

ALTER TABLE `Products` DROP COLUMN `ImageUrl`;

CREATE TABLE `ProductImage` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `FileName` longtext NOT NULL,
    `ProductId` int NOT NULL,
    PRIMARY KEY (`Id`),
    CONSTRAINT `FK_ProductImage_Products_ProductId` FOREIGN KEY (`ProductId`) REFERENCES `Products` (`Id`) ON DELETE CASCADE
);

CREATE INDEX `IX_ProductImage_ProductId` ON `ProductImage` (`ProductId`);

INSERT INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`)
VALUES ('20250117084923_convert image to list', '8.0.11');

COMMIT;

START TRANSACTION;

ALTER TABLE `Products` ADD `Brand` longtext NULL;

INSERT INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`)
VALUES ('20250118093156_update database va them brand', '8.0.11');

COMMIT;

START TRANSACTION;

ALTER TABLE `ProductDetails` DROP COLUMN `Color`;

INSERT INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`)
VALUES ('20250120142435_drop column color', '8.0.11');

COMMIT;

START TRANSACTION;

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Doloribus sunt recusandae molestias et quia expedita culpa doloribus enim occaecati doloribus est quia dolor est id.', 'Ipsam autem molestias soluta atque unde rerum distinctio velit quidem iure ipsum accusantium sapiente qui.', 1393471.155498862, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Modi non similique fugit ab ex cupiditate rerum non ea ut itaque.', 'Ex ipsam nihil placeat in reprehenderit dolore enim sunt.', 2547011.7337755, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Ea aut voluptatem adipisci illum et iste mollitia deserunt omnis natus voluptatum dolorem non.', 'Odio maiores minus iste amet nisi est recusandae veniam.', 1285710.5453897784, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Minima natus alias pariatur eos magni qui hic quo ipsa suscipit voluptas magni nobis et rerum.', 'Et autem quo quaerat eius eos tenetur voluptatem culpa provident.', 1792629.437890196, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Cum architecto id quia quasi delectus repellat mollitia quod.', 'Molestiae et eius illum modi aut expedita id accusamus iure in eum et corrupti.', 1932747.018026536, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Inventore nihil quae officia iste mollitia fuga libero aperiam delectus mollitia sed.', 'Quisquam aut aliquid id debitis.', 2461136.04375214, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Eaque ea repudiandae pariatur id reiciendis nam.', 'Debitis exercitationem rerum magnam necessitatibus qui et sunt unde voluptatem et eum doloremque unde dolor quaerat molestias.', 2818346.698683848, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Voluptatem culpa ab omnis iste quia ab qui expedita excepturi adipisci voluptatibus culpa.', 'Vel autem id quia nisi enim voluptatum illum ut et qui vel sed sequi quos dolorum et nisi voluptatem.', 2733280.137988404, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Incidunt eum occaecati dicta magni voluptas magni magnam veritatis aliquid ipsum corrupti eveniet.', 'Possimus quae recusandae neque qui quasi suscipit ut.', 1980872.089500012, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quod officia saepe sapiente aperiam vero at fugiat ratione quam.', 'Sapiente eius ut numquam rem nisi error quia qui veniam quia quidem earum minus.', 3304309.926137472, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Dolor consequatur commodi sit aut qui adipisci nisi perspiciatis hic ipsum numquam sed dolores suscipit nisi.', 'Harum quibusdam dolorem optio hic tempore est assumenda quia autem ipsa quam.', 4797582.901919996, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Tempora praesentium eos tempore dolorem dolor labore cumque autem accusantium necessitatibus libero occaecati ipsum aliquid ut tenetur rerum voluptatibus nesciunt.', 'Recusandae placeat voluptatem tempora suscipit rerum velit nihil autem.', 1608887.564674432, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Deserunt asperiores rerum possimus et qui molestias natus labore non nihil et aut minima voluptatem iste quam quia quo.', 'Odio temporibus facilis nostrum impedit sed.', 2784613.692101376, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Qui dolorem repellat qui officiis delectus beatae cupiditate tempora deserunt et magni.', 'Quam et vel excepturi hic numquam hic amet vitae asperiores et tenetur.', 1232421.651590812, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Aut aliquid et ab hic autem voluptatem quam esse recusandae voluptas non.', 'Sed fuga voluptas dolorem corporis impedit expedita sit accusamus ut omnis possimus ut dolores corporis inventore fugiat dolores.', 3516310.69859318, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Deleniti enim quia sunt ut tenetur facere esse repellat molestias dignissimos tempore voluptatem quis maxime natus facere dolorem.', 'Dolore ea totam itaque dicta debitis nostrum quae.', 4517206.221594104, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Commodi culpa iusto non fugit commodi non ducimus possimus veniam ut tenetur labore sit ea qui.', 'Id non facere quod corporis nam.', 2193785.131533532, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Velit aut suscipit sunt optio magnam voluptates officiis cumque quidem molestiae.', 'Laudantium voluptates aut vel aut.', 4989319.577808176, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Pariatur exercitationem neque qui in voluptatem est omnis sint consequuntur aut inventore sint eos eum cumque aliquid mollitia ea.', 'Aperiam odio beatae ut vel.', 2740923.604807316, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Rerum eum occaecati itaque et nemo repellendus ducimus sunt magnam natus omnis dolorem et optio reprehenderit placeat est.', 'Aut accusamus quidem quia expedita eius facere recusandae nulla velit numquam fuga quasi qui.', 2804403.557351048, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Est repellat consectetur ut facere dolores eligendi.', 'Qui autem quo sed eos suscipit quae sit vel et molestiae rerum alias fuga eos porro.', 4509724.527369124, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Itaque aperiam officiis fuga quos dolorum autem autem aut qui.', 'Vel dolorem debitis dolor eveniet possimus et eum numquam quibusdam excepturi consequatur rerum.', 4244622.513300096, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quo molestias consequuntur aut dolores voluptatum totam eum adipisci.', 'Et dolorem corporis eius neque ut commodi est est iusto reiciendis omnis assumenda odit et.', 4987909.929821224, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Distinctio sunt molestiae libero doloribus vel modi et accusamus nam.', 'Voluptatem vitae voluptates dignissimos soluta occaecati aperiam non natus dolorem illo qui ratione porro fugit autem nostrum neque.', 3954229.527597424, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Ut eos qui consequatur consequatur.', 'Maiores officiis aut beatae enim exercitationem nobis corrupti iure est cupiditate provident accusamus dolore quasi itaque iusto.', 1655312.020636776, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quia minima hic debitis odio non quod magni rerum rerum quia itaque aut harum.', 'Provident nesciunt sint atque at omnis assumenda distinctio voluptas nihil pariatur possimus nostrum quos tenetur exercitationem nihil reiciendis sed.', 3755065.3343811, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Aperiam repellat sunt ratione sunt dolorem ipsa pariatur ut facere nihil ut.', 'Quo voluptates sit tenetur nemo nulla ex et fuga qui officia quia ducimus quidem est nisi quam sapiente ut earum.', 2666374.674842868, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Nesciunt nisi suscipit veniam mollitia est consequatur veritatis tempore molestiae at sit.', 'Ipsa minima placeat libero ex suscipit officiis velit unde maiores aut quia non aliquid molestias nulla temporibus.', 3093404.064929768, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Perspiciatis numquam placeat tempore et accusantium magnam et consequatur natus dolor nesciunt voluptatem sed vero est veritatis libero nostrum perspiciatis.', 'Ut dicta laborum ex ea nesciunt et autem corporis eius aut et eveniet repellendus.', 3263756.218489144, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Id magni facilis odit impedit et at voluptas eum.', 'Consequatur tempore nihil dignissimos quia et reiciendis aliquid alias magni dolores ipsam quaerat accusamus sit.', 2012048.868933716, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Laboriosam ut aliquam nihil sit nostrum ex praesentium sed facilis odio ut rem.', 'Pariatur non nihil voluptatem qui libero eos ipsa.', 2514023.958479064, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Perspiciatis dolor iusto sequi quis officiis omnis et blanditiis error excepturi eos sunt incidunt cum vel ut voluptatibus quidem.', 'Ut qui non eveniet quis temporibus omnis porro repellendus qui rerum ullam cupiditate sit debitis unde at sed.', 1690406.745621192, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Accusamus sint dignissimos voluptates porro doloribus a voluptatum rem perferendis quia aut ea cupiditate eum.', 'Aliquam sed accusamus et quia inventore.', 1546892.131002104, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Molestiae numquam suscipit labore aliquid magni non ratione consequatur aut maiores accusantium consequatur dolorum sit ullam eum beatae.', 'Est voluptatem omnis saepe alias rerum repellendus exercitationem.', 2264303.308569036, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Tempore nisi consequatur vel sunt maiores et et porro quia.', 'Corrupti dolor quasi et sed ex sunt harum ex sunt.', 3676863.591501892, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Vel commodi est neque quia suscipit nostrum similique.', 'Non consequatur dolores harum quia est et quidem soluta facilis fugit a ut veniam vitae est praesentium laudantium.', 3363493.70068102, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Distinctio a voluptas consequatur aspernatur repellat perferendis sapiente qui dolor ipsam nihil omnis molestias minima consequatur.', 'Et commodi impedit expedita asperiores cum molestiae iste quis repudiandae vitae non voluptatum eos officiis cumque officiis quia magnam.', 1188328.463671882, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Sed dolor quidem totam illum quas voluptas.', 'Ea qui consequatur porro possimus distinctio aspernatur aut eaque nam veniam quo ducimus consequatur dicta non.', 2749545.150319832, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Ipsam dignissimos quisquam cum sit accusantium voluptatem et voluptatem amet.', 'Amet dolor quia mollitia et rerum.', 3063410.176925088, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Consequatur porro sed est illum fugiat.', 'Delectus non nobis qui sunt nihil doloremque rem amet rerum delectus est et.', 4912888.502661552, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Tenetur in repudiandae vel pariatur corrupti aut labore culpa et similique.', 'Et et fugit tempore ut nulla qui inventore aut sed sed explicabo consequatur nesciunt impedit maiores quo eveniet.', 1638640.197291336, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Aspernatur voluptate voluptas et vero consequatur voluptatibus voluptatem vero ut aut aut.', 'Pariatur in voluptas quasi non et aut et sint quis quo eos qui.', 2782282.84874106, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Omnis quia non soluta voluptas sed possimus eius et enim vel saepe eos et velit qui.', 'Minus sunt sint possimus et.', 4661396.92611126, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Fugiat minima quia dolor sed molestiae earum eaque natus nostrum et id dignissimos.', 'Ipsa ea explicabo sit reiciendis omnis qui ipsum voluptatem odio porro.', 1591094.238958832, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Magni dolore non itaque repudiandae quia voluptatem nulla atque voluptates in aspernatur itaque quis omnis suscipit similique iste.', 'Cumque deserunt est dolorem quam in necessitatibus sequi odit nam quaerat voluptas.', 2844267.201537392, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Aut consequatur temporibus harum aliquid sit provident quam in iste dolores sint vitae ipsa reprehenderit dolorum quo qui rerum aliquam.', 'Incidunt dignissimos vitae molestias commodi voluptatem ab sint sit tempora qui fugit.', 1512679.219484644, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Natus maiores cumque eius tempora recusandae minima sit magni tempore ut quos pariatur voluptas corrupti eum aut aut.', 'Cupiditate officiis consequatur impedit quia doloribus nemo deleniti.', 3006795.619617588, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Sit aliquid ea tenetur quia eum harum dolores ut expedita quia.', 'Numquam enim voluptate id accusamus quia quis.', 2721426.688936272, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quam quaerat voluptates id a adipisci minima culpa tempora sint.', 'Omnis fuga et quia et ut rerum itaque at optio sunt modi.', 4535026.246465288, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Distinctio inventore ullam sint quia magni adipisci quasi eaque voluptates.', 'Quos ut magnam quidem ex omnis.', 1024014.62757215584, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Accusamus reprehenderit officia molestias dicta odit voluptas sed aliquid in expedita nulla aperiam accusantium magnam ullam.', 'Reiciendis veritatis odit repellendus quaerat impedit qui.', 4570163.223692292, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Aut adipisci reprehenderit ullam et qui similique atque.', 'Delectus architecto omnis numquam velit.', 4171616.494269864, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Voluptas dolores eum veritatis illo totam aspernatur hic et autem quos eveniet tenetur est.', 'Alias et vero explicabo dolores ratione ab architecto sint minima omnis aut veniam tempora qui.', 4062857.282842908, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Ipsam consectetur esse non sed eum quia perspiciatis explicabo odio et consequuntur et libero provident.', 'Veniam quasi recusandae ea ipsam expedita ducimus autem quam et repellendus.', 3014586.840763032, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Vel est repudiandae est quo qui voluptas adipisci rem et repellendus soluta.', 'Eaque impedit dolore hic et laborum voluptatem est alias nesciunt est voluptate suscipit.', 3621969.902246244, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Dolorum autem suscipit quae tempore dicta minima quo rerum sint vel vitae voluptas non vel ut.', 'Cum voluptas et quod unde totam alias.', 1694611.49382154, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Nulla vel similique voluptatem sed quas non accusantium sunt cum laudantium quod.', 'Laudantium possimus asperiores ea et.', 1213333.6645613116, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Aliquam qui consectetur necessitatibus et qui sunt eaque repellat architecto quia suscipit accusamus.', 'Et totam ratione dolorum ipsam nemo voluptatem quod.', 3558353.982194492, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Et voluptate tempore ullam vero placeat amet.', 'Hic facilis tempora qui fuga.', 3719654.913395484, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Rem non saepe accusantium dolores aliquid magni accusamus illum modi nostrum nulla id sed maxime autem sint.', 'Illo dicta sunt inventore ad dolor dolore necessitatibus nostrum iure tempora sapiente autem nulla totam vero nulla.', 2511945.794109228, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quo qui repellendus tempore ut at architecto similique ut.', 'Sint sed ut quo eligendi similique mollitia cum esse expedita porro dolor.', 3426818.902803036, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Maxime facilis at et dignissimos vel.', 'Ad consequatur sed et laborum enim velit omnis sed velit est nisi odio quis sit a magnam aspernatur ad.', 4486501.013620992, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Molestiae quisquam perspiciatis non sed quisquam non.', 'Alias facilis consequuntur cupiditate similique facilis quo voluptatem voluptates beatae ullam sit quia non praesentium odit iusto dolorem eligendi.', 3245448.804574764, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Animi sit dolorem molestias optio nulla facilis sunt accusamus architecto unde atque expedita sed omnis.', 'Qui accusamus qui ut aut nisi sit reiciendis est inventore numquam quaerat.', 2748346.025938328, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quis doloremque consequatur non in enim a perferendis accusamus et consectetur in.', 'Alias placeat optio totam aut.', 4627875.549545456, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Et ullam sapiente numquam aut quaerat enim consectetur illum rerum et iure eos autem.', 'Occaecati sed dignissimos et et non aut repellat non sequi incidunt nemo sit tempora asperiores officia.', 1818940.3511672, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Vel debitis architecto et voluptatem sit eos repellat assumenda adipisci.', 'Ipsum aut odio distinctio ullam incidunt in accusantium.', 1840345.830116584, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Aspernatur vel ullam aperiam veritatis est tenetur exercitationem sapiente dolorem illo nihil aperiam quia et.', 'Blanditiis ut fugit distinctio dolore possimus est assumenda possimus aliquid temporibus facilis quisquam repellat esse.', 3253010.858899452, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Est porro et omnis doloremque sunt soluta amet cumque aut quis quia placeat assumenda sed nesciunt nam est est voluptates.', 'Quam laboriosam sed non minima impedit eos nemo in sapiente voluptate quos molestiae.', 2381759.10216838, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Iusto vero nihil debitis iusto voluptatum perspiciatis tenetur labore mollitia aut culpa tempore corrupti.', 'Modi consequatur et ducimus enim.', 2517651.45990888, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Dolore facere vel qui debitis quia voluptas delectus nobis voluptatem nihil excepturi quisquam aut aliquid minus rem architecto.', 'Eum delectus recusandae ut magni amet qui cupiditate quod mollitia quo voluptatibus architecto tempora sunt est tempore dolores.', 3460368.7927408, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quam fugit enim voluptates est sequi neque voluptas dolore officiis beatae dolor quis qui.', 'Eveniet ipsam atque magnam harum inventore animi aut consequatur pariatur suscipit ut veniam voluptatem velit soluta ut vero voluptatum qui.', 2082693.793383748, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Voluptatem in aut accusantium inventore ad et occaecati expedita est soluta incidunt cum exercitationem amet et.', 'Sed qui aut et inventore ex aut debitis et ab adipisci voluptas quia saepe earum est quia nostrum et minima.', 3437979.969399972, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quia ut nulla adipisci est.', 'Illo voluptatum ut quos doloribus debitis itaque harum quaerat temporibus delectus modi dolorem ratione dignissimos.', 1897150.520653068, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Soluta suscipit porro quod quas totam alias veniam delectus quis sed dolores omnis inventore et.', 'Eos qui qui ratione cumque pariatur dignissimos tenetur enim totam quam voluptas soluta fugit laudantium.', 3234341.447350728, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Natus dolorem vero aut non unde.', 'Ut non accusantium quas ea.', 1541024.82299368, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Qui aspernatur mollitia accusantium quia corporis architecto aut eum necessitatibus omnis molestiae.', 'Ab cum animi pariatur voluptates.', 4913986.651186824, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Eius necessitatibus consequatur et non ad dolores dolore corrupti qui itaque.', 'Quia maiores est tempora dicta dicta eos quaerat accusantium officia laboriosam ut magnam.', 2997492.252847876, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Tenetur tempora laborum quia mollitia nihil quod voluptatem voluptas explicabo reiciendis illum ab.', 'Eum atque consequatur tenetur quia aliquam illo.', 2455900.718204632, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Excepturi voluptas assumenda quisquam quis et unde eaque consequatur impedit voluptas sit.', 'Debitis est nisi magni iusto.', 3877406.95051728, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Dolores odit enim sunt sunt adipisci aut suscipit sit ipsa et blanditiis officia omnis aspernatur velit dolorem cumque.', 'Quidem exercitationem illo laborum odit veniam voluptatibus aut id ea.', 3440628.600511992, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Illum suscipit occaecati enim ea dolores.', 'Et quia non numquam voluptatem quia totam enim deserunt et dolor ut sint molestiae quasi.', 1338485.4161825428, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Vitae dolores neque aut aut reprehenderit et aut voluptate delectus nihil sed quasi.', 'Eligendi sint qui architecto consectetur odit beatae aperiam quis rerum aut reprehenderit.', 3241342.400313048, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quia explicabo et placeat magnam delectus incidunt voluptates sit debitis occaecati repellendus doloremque labore et ea ipsa consectetur.', 'Omnis sunt voluptatem quis aliquid debitis reiciendis rem ab non cupiditate eum quisquam.', 4324948.763160476, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Pariatur enim enim tempore et aut labore repellendus officia ut omnis voluptate beatae voluptas quam.', 'Animi dolor et repellendus id aut quisquam ullam officiis ad dolores dolor cumque aut ab et tenetur ex iure.', 2212030.3330999, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Consequatur quia quam ut corporis.', 'Odit et totam eveniet harum harum minima molestiae quae at quae itaque ipsa deserunt perferendis et.', 3371076.551438812, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Inventore dicta dolor eius placeat blanditiis est qui fugit aut incidunt blanditiis ducimus dolore.', 'Architecto et et ea autem eos unde quam aut alias hic.', 4619197.15051502, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Nisi quo aperiam similique minus vel deleniti eius hic necessitatibus ab.', 'Quia sit sint qui eligendi.', 3355033.951976816, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Et molestias delectus aut sint qui numquam maxime molestias nam eveniet.', 'Et omnis enim odit ea pariatur nam est.', 3539677.282115296, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Numquam consequuntur qui ducimus reprehenderit sed soluta aperiam voluptatem amet velit perspiciatis aut et autem id occaecati.', 'Sint et ut omnis illo tempore magnam.', 2849957.057205008, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Architecto fugit unde accusantium eos assumenda eaque exercitationem voluptas dolore et alias perferendis veritatis voluptatum rerum impedit et.', 'Ducimus ea minus nam sit quos non similique autem.', 3642434.521877408, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Inventore velit non laboriosam est sint.', 'Nesciunt unde est et laborum provident quos qui ipsum quas alias dolores.', 4641000.550073104, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Accusamus asperiores perferendis praesentium nisi qui eius sed et sed.', 'Harum assumenda amet et quasi tempore blanditiis iste.', 1661556.264693644, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Magnam atque eum temporibus velit ipsum debitis quia impedit error ullam placeat qui.', 'Quia sint debitis voluptatem totam quaerat fuga eveniet.', 3287024.988926492, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Reiciendis omnis nemo qui aspernatur eum unde earum maxime autem et molestias harum tempore ratione veniam laboriosam non.', 'Quidem rerum rerum ipsa alias distinctio sequi quibusdam consectetur dicta et molestiae ex voluptates natus vel iusto et nostrum tempora.', 4515723.446158564, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Ex consequatur itaque sunt optio.', 'Quia sed amet sint esse hic recusandae debitis explicabo.', 3888761.680055764, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Molestiae earum aperiam ex at quo et voluptatem mollitia.', 'Vero impedit esse ab voluptatibus et.', 3479185.899011412, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Debitis aut et sapiente officiis officia quasi ut maiores molestias ea reiciendis nobis porro.', 'Natus commodi quis nulla nam quas dolorem quasi nemo aspernatur numquam ut voluptate assumenda et et.', 4534417.591772236, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quis numquam dolorum officiis sapiente quasi dignissimos veniam tenetur at.', 'Vero dolorum eum eos repellat vero est optio modi a.', 1337497.435667318, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Doloremque quia et expedita labore distinctio magni sed beatae occaecati nam in quas explicabo nobis ea.', 'In vel omnis ipsam porro qui deleniti eum.', 1836533.80201968, 'Adidas');

INSERT INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`)
VALUES ('20250123122250_fake data', '8.0.11');

COMMIT;

START TRANSACTION;

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Doloribus sunt recusandae molestias et quia expedita culpa doloribus enim occaecati doloribus est quia dolor est id.', 'Ipsam autem molestias soluta atque unde rerum distinctio velit quidem iure ipsum accusantium sapiente qui.', 1393471.155498862, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Modi non similique fugit ab ex cupiditate rerum non ea ut itaque.', 'Ex ipsam nihil placeat in reprehenderit dolore enim sunt.', 2547011.7337755, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Ea aut voluptatem adipisci illum et iste mollitia deserunt omnis natus voluptatum dolorem non.', 'Odio maiores minus iste amet nisi est recusandae veniam.', 1285710.5453897784, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Minima natus alias pariatur eos magni qui hic quo ipsa suscipit voluptas magni nobis et rerum.', 'Et autem quo quaerat eius eos tenetur voluptatem culpa provident.', 1792629.437890196, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Cum architecto id quia quasi delectus repellat mollitia quod.', 'Molestiae et eius illum modi aut expedita id accusamus iure in eum et corrupti.', 1932747.018026536, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Inventore nihil quae officia iste mollitia fuga libero aperiam delectus mollitia sed.', 'Quisquam aut aliquid id debitis.', 2461136.04375214, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Eaque ea repudiandae pariatur id reiciendis nam.', 'Debitis exercitationem rerum magnam necessitatibus qui et sunt unde voluptatem et eum doloremque unde dolor quaerat molestias.', 2818346.698683848, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Voluptatem culpa ab omnis iste quia ab qui expedita excepturi adipisci voluptatibus culpa.', 'Vel autem id quia nisi enim voluptatum illum ut et qui vel sed sequi quos dolorum et nisi voluptatem.', 2733280.137988404, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Incidunt eum occaecati dicta magni voluptas magni magnam veritatis aliquid ipsum corrupti eveniet.', 'Possimus quae recusandae neque qui quasi suscipit ut.', 1980872.089500012, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quod officia saepe sapiente aperiam vero at fugiat ratione quam.', 'Sapiente eius ut numquam rem nisi error quia qui veniam quia quidem earum minus.', 3304309.926137472, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Dolor consequatur commodi sit aut qui adipisci nisi perspiciatis hic ipsum numquam sed dolores suscipit nisi.', 'Harum quibusdam dolorem optio hic tempore est assumenda quia autem ipsa quam.', 4797582.901919996, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Tempora praesentium eos tempore dolorem dolor labore cumque autem accusantium necessitatibus libero occaecati ipsum aliquid ut tenetur rerum voluptatibus nesciunt.', 'Recusandae placeat voluptatem tempora suscipit rerum velit nihil autem.', 1608887.564674432, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Deserunt asperiores rerum possimus et qui molestias natus labore non nihil et aut minima voluptatem iste quam quia quo.', 'Odio temporibus facilis nostrum impedit sed.', 2784613.692101376, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Qui dolorem repellat qui officiis delectus beatae cupiditate tempora deserunt et magni.', 'Quam et vel excepturi hic numquam hic amet vitae asperiores et tenetur.', 1232421.651590812, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Aut aliquid et ab hic autem voluptatem quam esse recusandae voluptas non.', 'Sed fuga voluptas dolorem corporis impedit expedita sit accusamus ut omnis possimus ut dolores corporis inventore fugiat dolores.', 3516310.69859318, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Deleniti enim quia sunt ut tenetur facere esse repellat molestias dignissimos tempore voluptatem quis maxime natus facere dolorem.', 'Dolore ea totam itaque dicta debitis nostrum quae.', 4517206.221594104, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Commodi culpa iusto non fugit commodi non ducimus possimus veniam ut tenetur labore sit ea qui.', 'Id non facere quod corporis nam.', 2193785.131533532, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Velit aut suscipit sunt optio magnam voluptates officiis cumque quidem molestiae.', 'Laudantium voluptates aut vel aut.', 4989319.577808176, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Pariatur exercitationem neque qui in voluptatem est omnis sint consequuntur aut inventore sint eos eum cumque aliquid mollitia ea.', 'Aperiam odio beatae ut vel.', 2740923.604807316, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Rerum eum occaecati itaque et nemo repellendus ducimus sunt magnam natus omnis dolorem et optio reprehenderit placeat est.', 'Aut accusamus quidem quia expedita eius facere recusandae nulla velit numquam fuga quasi qui.', 2804403.557351048, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Est repellat consectetur ut facere dolores eligendi.', 'Qui autem quo sed eos suscipit quae sit vel et molestiae rerum alias fuga eos porro.', 4509724.527369124, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Itaque aperiam officiis fuga quos dolorum autem autem aut qui.', 'Vel dolorem debitis dolor eveniet possimus et eum numquam quibusdam excepturi consequatur rerum.', 4244622.513300096, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quo molestias consequuntur aut dolores voluptatum totam eum adipisci.', 'Et dolorem corporis eius neque ut commodi est est iusto reiciendis omnis assumenda odit et.', 4987909.929821224, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Distinctio sunt molestiae libero doloribus vel modi et accusamus nam.', 'Voluptatem vitae voluptates dignissimos soluta occaecati aperiam non natus dolorem illo qui ratione porro fugit autem nostrum neque.', 3954229.527597424, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Ut eos qui consequatur consequatur.', 'Maiores officiis aut beatae enim exercitationem nobis corrupti iure est cupiditate provident accusamus dolore quasi itaque iusto.', 1655312.020636776, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quia minima hic debitis odio non quod magni rerum rerum quia itaque aut harum.', 'Provident nesciunt sint atque at omnis assumenda distinctio voluptas nihil pariatur possimus nostrum quos tenetur exercitationem nihil reiciendis sed.', 3755065.3343811, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Aperiam repellat sunt ratione sunt dolorem ipsa pariatur ut facere nihil ut.', 'Quo voluptates sit tenetur nemo nulla ex et fuga qui officia quia ducimus quidem est nisi quam sapiente ut earum.', 2666374.674842868, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Nesciunt nisi suscipit veniam mollitia est consequatur veritatis tempore molestiae at sit.', 'Ipsa minima placeat libero ex suscipit officiis velit unde maiores aut quia non aliquid molestias nulla temporibus.', 3093404.064929768, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Perspiciatis numquam placeat tempore et accusantium magnam et consequatur natus dolor nesciunt voluptatem sed vero est veritatis libero nostrum perspiciatis.', 'Ut dicta laborum ex ea nesciunt et autem corporis eius aut et eveniet repellendus.', 3263756.218489144, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Id magni facilis odit impedit et at voluptas eum.', 'Consequatur tempore nihil dignissimos quia et reiciendis aliquid alias magni dolores ipsam quaerat accusamus sit.', 2012048.868933716, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Laboriosam ut aliquam nihil sit nostrum ex praesentium sed facilis odio ut rem.', 'Pariatur non nihil voluptatem qui libero eos ipsa.', 2514023.958479064, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Perspiciatis dolor iusto sequi quis officiis omnis et blanditiis error excepturi eos sunt incidunt cum vel ut voluptatibus quidem.', 'Ut qui non eveniet quis temporibus omnis porro repellendus qui rerum ullam cupiditate sit debitis unde at sed.', 1690406.745621192, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Accusamus sint dignissimos voluptates porro doloribus a voluptatum rem perferendis quia aut ea cupiditate eum.', 'Aliquam sed accusamus et quia inventore.', 1546892.131002104, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Molestiae numquam suscipit labore aliquid magni non ratione consequatur aut maiores accusantium consequatur dolorum sit ullam eum beatae.', 'Est voluptatem omnis saepe alias rerum repellendus exercitationem.', 2264303.308569036, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Tempore nisi consequatur vel sunt maiores et et porro quia.', 'Corrupti dolor quasi et sed ex sunt harum ex sunt.', 3676863.591501892, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Vel commodi est neque quia suscipit nostrum similique.', 'Non consequatur dolores harum quia est et quidem soluta facilis fugit a ut veniam vitae est praesentium laudantium.', 3363493.70068102, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Distinctio a voluptas consequatur aspernatur repellat perferendis sapiente qui dolor ipsam nihil omnis molestias minima consequatur.', 'Et commodi impedit expedita asperiores cum molestiae iste quis repudiandae vitae non voluptatum eos officiis cumque officiis quia magnam.', 1188328.463671882, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Sed dolor quidem totam illum quas voluptas.', 'Ea qui consequatur porro possimus distinctio aspernatur aut eaque nam veniam quo ducimus consequatur dicta non.', 2749545.150319832, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Ipsam dignissimos quisquam cum sit accusantium voluptatem et voluptatem amet.', 'Amet dolor quia mollitia et rerum.', 3063410.176925088, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Consequatur porro sed est illum fugiat.', 'Delectus non nobis qui sunt nihil doloremque rem amet rerum delectus est et.', 4912888.502661552, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Tenetur in repudiandae vel pariatur corrupti aut labore culpa et similique.', 'Et et fugit tempore ut nulla qui inventore aut sed sed explicabo consequatur nesciunt impedit maiores quo eveniet.', 1638640.197291336, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Aspernatur voluptate voluptas et vero consequatur voluptatibus voluptatem vero ut aut aut.', 'Pariatur in voluptas quasi non et aut et sint quis quo eos qui.', 2782282.84874106, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Omnis quia non soluta voluptas sed possimus eius et enim vel saepe eos et velit qui.', 'Minus sunt sint possimus et.', 4661396.92611126, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Fugiat minima quia dolor sed molestiae earum eaque natus nostrum et id dignissimos.', 'Ipsa ea explicabo sit reiciendis omnis qui ipsum voluptatem odio porro.', 1591094.238958832, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Magni dolore non itaque repudiandae quia voluptatem nulla atque voluptates in aspernatur itaque quis omnis suscipit similique iste.', 'Cumque deserunt est dolorem quam in necessitatibus sequi odit nam quaerat voluptas.', 2844267.201537392, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Aut consequatur temporibus harum aliquid sit provident quam in iste dolores sint vitae ipsa reprehenderit dolorum quo qui rerum aliquam.', 'Incidunt dignissimos vitae molestias commodi voluptatem ab sint sit tempora qui fugit.', 1512679.219484644, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Natus maiores cumque eius tempora recusandae minima sit magni tempore ut quos pariatur voluptas corrupti eum aut aut.', 'Cupiditate officiis consequatur impedit quia doloribus nemo deleniti.', 3006795.619617588, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Sit aliquid ea tenetur quia eum harum dolores ut expedita quia.', 'Numquam enim voluptate id accusamus quia quis.', 2721426.688936272, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quam quaerat voluptates id a adipisci minima culpa tempora sint.', 'Omnis fuga et quia et ut rerum itaque at optio sunt modi.', 4535026.246465288, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Distinctio inventore ullam sint quia magni adipisci quasi eaque voluptates.', 'Quos ut magnam quidem ex omnis.', 1024014.62757215584, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Accusamus reprehenderit officia molestias dicta odit voluptas sed aliquid in expedita nulla aperiam accusantium magnam ullam.', 'Reiciendis veritatis odit repellendus quaerat impedit qui.', 4570163.223692292, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Aut adipisci reprehenderit ullam et qui similique atque.', 'Delectus architecto omnis numquam velit.', 4171616.494269864, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Voluptas dolores eum veritatis illo totam aspernatur hic et autem quos eveniet tenetur est.', 'Alias et vero explicabo dolores ratione ab architecto sint minima omnis aut veniam tempora qui.', 4062857.282842908, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Ipsam consectetur esse non sed eum quia perspiciatis explicabo odio et consequuntur et libero provident.', 'Veniam quasi recusandae ea ipsam expedita ducimus autem quam et repellendus.', 3014586.840763032, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Vel est repudiandae est quo qui voluptas adipisci rem et repellendus soluta.', 'Eaque impedit dolore hic et laborum voluptatem est alias nesciunt est voluptate suscipit.', 3621969.902246244, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Dolorum autem suscipit quae tempore dicta minima quo rerum sint vel vitae voluptas non vel ut.', 'Cum voluptas et quod unde totam alias.', 1694611.49382154, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Nulla vel similique voluptatem sed quas non accusantium sunt cum laudantium quod.', 'Laudantium possimus asperiores ea et.', 1213333.6645613116, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Aliquam qui consectetur necessitatibus et qui sunt eaque repellat architecto quia suscipit accusamus.', 'Et totam ratione dolorum ipsam nemo voluptatem quod.', 3558353.982194492, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Et voluptate tempore ullam vero placeat amet.', 'Hic facilis tempora qui fuga.', 3719654.913395484, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Rem non saepe accusantium dolores aliquid magni accusamus illum modi nostrum nulla id sed maxime autem sint.', 'Illo dicta sunt inventore ad dolor dolore necessitatibus nostrum iure tempora sapiente autem nulla totam vero nulla.', 2511945.794109228, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quo qui repellendus tempore ut at architecto similique ut.', 'Sint sed ut quo eligendi similique mollitia cum esse expedita porro dolor.', 3426818.902803036, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Maxime facilis at et dignissimos vel.', 'Ad consequatur sed et laborum enim velit omnis sed velit est nisi odio quis sit a magnam aspernatur ad.', 4486501.013620992, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Molestiae quisquam perspiciatis non sed quisquam non.', 'Alias facilis consequuntur cupiditate similique facilis quo voluptatem voluptates beatae ullam sit quia non praesentium odit iusto dolorem eligendi.', 3245448.804574764, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Animi sit dolorem molestias optio nulla facilis sunt accusamus architecto unde atque expedita sed omnis.', 'Qui accusamus qui ut aut nisi sit reiciendis est inventore numquam quaerat.', 2748346.025938328, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quis doloremque consequatur non in enim a perferendis accusamus et consectetur in.', 'Alias placeat optio totam aut.', 4627875.549545456, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Et ullam sapiente numquam aut quaerat enim consectetur illum rerum et iure eos autem.', 'Occaecati sed dignissimos et et non aut repellat non sequi incidunt nemo sit tempora asperiores officia.', 1818940.3511672, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Vel debitis architecto et voluptatem sit eos repellat assumenda adipisci.', 'Ipsum aut odio distinctio ullam incidunt in accusantium.', 1840345.830116584, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Aspernatur vel ullam aperiam veritatis est tenetur exercitationem sapiente dolorem illo nihil aperiam quia et.', 'Blanditiis ut fugit distinctio dolore possimus est assumenda possimus aliquid temporibus facilis quisquam repellat esse.', 3253010.858899452, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Est porro et omnis doloremque sunt soluta amet cumque aut quis quia placeat assumenda sed nesciunt nam est est voluptates.', 'Quam laboriosam sed non minima impedit eos nemo in sapiente voluptate quos molestiae.', 2381759.10216838, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Iusto vero nihil debitis iusto voluptatum perspiciatis tenetur labore mollitia aut culpa tempore corrupti.', 'Modi consequatur et ducimus enim.', 2517651.45990888, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Dolore facere vel qui debitis quia voluptas delectus nobis voluptatem nihil excepturi quisquam aut aliquid minus rem architecto.', 'Eum delectus recusandae ut magni amet qui cupiditate quod mollitia quo voluptatibus architecto tempora sunt est tempore dolores.', 3460368.7927408, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quam fugit enim voluptates est sequi neque voluptas dolore officiis beatae dolor quis qui.', 'Eveniet ipsam atque magnam harum inventore animi aut consequatur pariatur suscipit ut veniam voluptatem velit soluta ut vero voluptatum qui.', 2082693.793383748, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Voluptatem in aut accusantium inventore ad et occaecati expedita est soluta incidunt cum exercitationem amet et.', 'Sed qui aut et inventore ex aut debitis et ab adipisci voluptas quia saepe earum est quia nostrum et minima.', 3437979.969399972, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quia ut nulla adipisci est.', 'Illo voluptatum ut quos doloribus debitis itaque harum quaerat temporibus delectus modi dolorem ratione dignissimos.', 1897150.520653068, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Soluta suscipit porro quod quas totam alias veniam delectus quis sed dolores omnis inventore et.', 'Eos qui qui ratione cumque pariatur dignissimos tenetur enim totam quam voluptas soluta fugit laudantium.', 3234341.447350728, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Natus dolorem vero aut non unde.', 'Ut non accusantium quas ea.', 1541024.82299368, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Qui aspernatur mollitia accusantium quia corporis architecto aut eum necessitatibus omnis molestiae.', 'Ab cum animi pariatur voluptates.', 4913986.651186824, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Eius necessitatibus consequatur et non ad dolores dolore corrupti qui itaque.', 'Quia maiores est tempora dicta dicta eos quaerat accusantium officia laboriosam ut magnam.', 2997492.252847876, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Tenetur tempora laborum quia mollitia nihil quod voluptatem voluptas explicabo reiciendis illum ab.', 'Eum atque consequatur tenetur quia aliquam illo.', 2455900.718204632, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Excepturi voluptas assumenda quisquam quis et unde eaque consequatur impedit voluptas sit.', 'Debitis est nisi magni iusto.', 3877406.95051728, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Dolores odit enim sunt sunt adipisci aut suscipit sit ipsa et blanditiis officia omnis aspernatur velit dolorem cumque.', 'Quidem exercitationem illo laborum odit veniam voluptatibus aut id ea.', 3440628.600511992, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Illum suscipit occaecati enim ea dolores.', 'Et quia non numquam voluptatem quia totam enim deserunt et dolor ut sint molestiae quasi.', 1338485.4161825428, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Vitae dolores neque aut aut reprehenderit et aut voluptate delectus nihil sed quasi.', 'Eligendi sint qui architecto consectetur odit beatae aperiam quis rerum aut reprehenderit.', 3241342.400313048, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quia explicabo et placeat magnam delectus incidunt voluptates sit debitis occaecati repellendus doloremque labore et ea ipsa consectetur.', 'Omnis sunt voluptatem quis aliquid debitis reiciendis rem ab non cupiditate eum quisquam.', 4324948.763160476, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Pariatur enim enim tempore et aut labore repellendus officia ut omnis voluptate beatae voluptas quam.', 'Animi dolor et repellendus id aut quisquam ullam officiis ad dolores dolor cumque aut ab et tenetur ex iure.', 2212030.3330999, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Consequatur quia quam ut corporis.', 'Odit et totam eveniet harum harum minima molestiae quae at quae itaque ipsa deserunt perferendis et.', 3371076.551438812, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Inventore dicta dolor eius placeat blanditiis est qui fugit aut incidunt blanditiis ducimus dolore.', 'Architecto et et ea autem eos unde quam aut alias hic.', 4619197.15051502, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Nisi quo aperiam similique minus vel deleniti eius hic necessitatibus ab.', 'Quia sit sint qui eligendi.', 3355033.951976816, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Et molestias delectus aut sint qui numquam maxime molestias nam eveniet.', 'Et omnis enim odit ea pariatur nam est.', 3539677.282115296, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Numquam consequuntur qui ducimus reprehenderit sed soluta aperiam voluptatem amet velit perspiciatis aut et autem id occaecati.', 'Sint et ut omnis illo tempore magnam.', 2849957.057205008, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Architecto fugit unde accusantium eos assumenda eaque exercitationem voluptas dolore et alias perferendis veritatis voluptatum rerum impedit et.', 'Ducimus ea minus nam sit quos non similique autem.', 3642434.521877408, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Inventore velit non laboriosam est sint.', 'Nesciunt unde est et laborum provident quos qui ipsum quas alias dolores.', 4641000.550073104, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Accusamus asperiores perferendis praesentium nisi qui eius sed et sed.', 'Harum assumenda amet et quasi tempore blanditiis iste.', 1661556.264693644, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Magnam atque eum temporibus velit ipsum debitis quia impedit error ullam placeat qui.', 'Quia sint debitis voluptatem totam quaerat fuga eveniet.', 3287024.988926492, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Reiciendis omnis nemo qui aspernatur eum unde earum maxime autem et molestias harum tempore ratione veniam laboriosam non.', 'Quidem rerum rerum ipsa alias distinctio sequi quibusdam consectetur dicta et molestiae ex voluptates natus vel iusto et nostrum tempora.', 4515723.446158564, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Ex consequatur itaque sunt optio.', 'Quia sed amet sint esse hic recusandae debitis explicabo.', 3888761.680055764, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Molestiae earum aperiam ex at quo et voluptatem mollitia.', 'Vero impedit esse ab voluptatibus et.', 3479185.899011412, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Debitis aut et sapiente officiis officia quasi ut maiores molestias ea reiciendis nobis porro.', 'Natus commodi quis nulla nam quas dolorem quasi nemo aspernatur numquam ut voluptate assumenda et et.', 4534417.591772236, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quis numquam dolorum officiis sapiente quasi dignissimos veniam tenetur at.', 'Vero dolorum eum eos repellat vero est optio modi a.', 1337497.435667318, 'Adidas');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Doloremque quia et expedita labore distinctio magni sed beatae occaecati nam in quas explicabo nobis ea.', 'In vel omnis ipsam porro qui deleniti eum.', 1836533.80201968, 'Adidas');

INSERT INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`)
VALUES ('20250123132554_fake data 2', '8.0.11');

COMMIT;

START TRANSACTION;

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (76, 48, 118);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (92, 42, 20);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (26, 44, 120);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (97, 38, 108);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (97, 44, 48);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (78, 44, 150);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (65, 39, 161);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (53, 44, 101);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (57, 47, 135);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (25, 43, 82);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (23, 35, 193);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (43, 36, 94);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (27, 37, 118);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (18, 35, 76);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (55, 48, 187);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (40, 42, 188);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (31, 39, 68);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (46, 45, 85);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (43, 38, 68);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (16, 40, 128);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (44, 35, 11);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (25, 46, 55);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (58, 43, 122);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (76, 42, 100);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (23, 42, 59);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (47, 48, 149);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (57, 37, 74);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (73, 48, 62);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (14, 45, 61);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (58, 35, 172);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (20, 36, 166);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (93, 44, 15);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (38, 39, 32);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (69, 46, 190);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (39, 42, 161);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (83, 38, 50);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (20, 48, 58);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (60, 42, 46);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (33, 44, 22);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (74, 36, 21);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (94, 48, 122);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (74, 43, 90);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (66, 38, 165);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (28, 36, 134);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (62, 47, 82);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (43, 40, 91);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (51, 38, 102);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (13, 40, 17);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (60, 42, 123);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (64, 44, 14);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (94, 43, 47);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (13, 45, 163);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (39, 43, 177);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (40, 37, 15);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (44, 47, 172);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (62, 48, 136);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (81, 47, 65);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (65, 38, 179);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (60, 47, 118);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (57, 37, 20);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (82, 35, 113);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (78, 38, 106);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (48, 42, 36);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (60, 35, 157);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (57, 36, 17);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (48, 44, 106);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (25, 48, 119);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (92, 46, 160);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (74, 39, 74);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (36, 41, 165);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (28, 46, 95);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (81, 42, 38);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (52, 43, 134);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (38, 37, 91);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (54, 38, 168);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (54, 36, 33);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (83, 36, 56);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (13, 39, 40);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (51, 47, 49);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (76, 35, 188);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (22, 36, 21);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (38, 39, 55);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (37, 45, 121);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (88, 48, 14);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (85, 46, 168);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (21, 40, 120);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (94, 38, 53);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (27, 41, 74);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (58, 37, 95);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (33, 39, 131);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (92, 45, 119);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (72, 37, 9);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (40, 37, 178);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (60, 37, 74);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (56, 48, 41);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (27, 37, 104);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (38, 39, 100);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (64, 46, 167);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (70, 48, 137);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (73, 45, 41);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (79, 35, 88);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (93, 48, 51);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (49, 36, 138);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (82, 45, 53);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (71, 40, 12);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (88, 44, 108);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (23, 39, 195);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (93, 48, 197);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (22, 39, 188);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (75, 35, 52);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (38, 43, 87);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (71, 46, 37);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (91, 43, 200);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (93, 45, 20);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (82, 42, 116);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (29, 48, 89);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (80, 46, 62);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (21, 42, 88);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (26, 46, 26);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (47, 46, 132);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (34, 44, 30);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (48, 41, 35);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (82, 48, 120);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (86, 48, 22);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (55, 38, 122);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (89, 36, 92);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (45, 47, 81);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (54, 48, 49);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (93, 37, 24);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (97, 41, 192);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (13, 41, 163);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (39, 44, 17);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (93, 40, 11);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (45, 40, 188);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (83, 47, 170);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (26, 43, 71);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (82, 39, 144);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (67, 35, 175);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (31, 45, 154);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (89, 41, 66);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (13, 46, 103);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (64, 46, 100);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (32, 37, 118);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (56, 48, 153);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (45, 48, 105);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (48, 44, 12);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (41, 45, 116);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (75, 37, 46);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (30, 40, 98);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (92, 36, 177);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (34, 35, 177);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (72, 40, 120);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (47, 37, 29);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (40, 48, 94);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (76, 38, 74);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (93, 38, 11);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (40, 46, 28);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (74, 42, 153);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (74, 39, 136);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (34, 40, 87);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (8, 39, 25);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (70, 38, 183);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (86, 44, 131);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (91, 35, 97);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (89, 35, 165);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (18, 48, 178);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (84, 39, 39);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (48, 43, 59);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (77, 42, 107);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (19, 48, 19);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (90, 36, 167);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (71, 39, 122);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (40, 35, 14);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (47, 36, 111);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (42, 41, 164);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (65, 46, 108);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (92, 43, 66);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (78, 41, 25);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (30, 42, 154);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (82, 47, 142);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (43, 45, 147);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (60, 35, 175);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (65, 37, 134);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (27, 45, 188);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (84, 40, 49);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (64, 35, 35);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (48, 36, 147);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (97, 37, 74);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (75, 36, 141);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (74, 41, 161);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (83, 42, 34);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (38, 35, 71);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (81, 46, 90);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (93, 35, 128);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (85, 45, 177);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (41, 48, 14);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (86, 43, 102);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (63, 40, 160);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (95, 40, 115);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (42, 46, 177);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (23, 47, 153);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (85, 40, 49);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (79, 42, 78);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (87, 46, 59);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (72, 42, 32);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (17, 36, 99);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (50, 40, 45);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (67, 47, 167);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (35, 38, 39);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (39, 40, 133);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (77, 41, 196);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (57, 45, 28);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (86, 48, 71);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (67, 43, 90);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (68, 48, 165);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (28, 47, 175);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (67, 47, 58);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (15, 47, 93);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (69, 42, 14);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (91, 42, 40);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (12, 41, 36);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (72, 36, 80);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (34, 37, 150);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (10, 38, 34);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (20, 46, 164);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (77, 48, 176);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (9, 36, 68);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (34, 44, 102);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (42, 44, 109);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (56, 47, 55);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (14, 48, 91);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (22, 43, 31);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (32, 48, 176);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (47, 48, 150);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (19, 43, 131);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (19, 48, 27);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (64, 47, 111);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (22, 47, 101);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (84, 45, 156);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (67, 39, 89);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (84, 45, 64);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (52, 48, 65);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (71, 48, 46);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (69, 41, 14);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (97, 43, 36);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (59, 37, 16);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (84, 38, 153);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (46, 47, 193);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (72, 47, 11);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (93, 39, 171);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (39, 43, 128);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (48, 43, 41);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (48, 43, 141);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (38, 40, 193);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (89, 48, 88);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (52, 37, 74);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (38, 38, 122);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (73, 46, 20);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (68, 40, 173);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (37, 45, 15);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (33, 45, 137);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (40, 39, 176);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (45, 42, 198);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (95, 36, 109);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (39, 42, 171);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (79, 42, 193);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (57, 37, 152);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (68, 43, 13);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (30, 43, 163);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (58, 45, 38);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (36, 36, 173);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (66, 35, 137);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (34, 42, 125);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (56, 36, 126);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (40, 40, 38);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (14, 40, 66);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (27, 47, 182);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (88, 46, 117);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (34, 43, 33);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (65, 36, 144);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (14, 46, 155);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (82, 44, 9);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (68, 44, 93);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (23, 42, 196);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (39, 35, 32);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (20, 39, 57);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (86, 37, 56);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (53, 39, 182);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (31, 40, 71);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (34, 39, 96);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (56, 44, 92);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (89, 41, 52);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (84, 42, 144);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (21, 40, 137);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (85, 35, 81);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (91, 42, 159);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (47, 37, 63);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (86, 45, 186);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (48, 42, 107);

INSERT INTO `ProductDetails` (`ProductId`, `Size`, `StockQuantity`)
VALUES (85, 43, 52);

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Vel ut voluptatibus quidem at ut qui non eveniet quis temporibus omnis porro repellendus qui.', 'Ullam cupiditate sit debitis unde at sed ipsum nam accusamus sint dignissimos voluptates porro doloribus.', 4830770.447771424, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Perferendis quia aut ea cupiditate eum explicabo aliquam sed accusamus et quia.', 'Eos officiis molestiae numquam suscipit.', 1962726.833747108, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Non ratione consequatur aut maiores accusantium consequatur.', 'Sit ullam eum beatae et est voluptatem omnis saepe alias rerum repellendus exercitationem ipsam.', 2337571.941938984, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Consequatur vel sunt maiores et et porro quia nisi corrupti.', 'Quasi et sed ex sunt harum ex.', 3282760.550399664, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Vel commodi est neque quia suscipit nostrum similique.', 'Non consequatur dolores harum quia est et quidem soluta facilis fugit a ut veniam vitae est praesentium laudantium.', 3363493.70068102, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('A voluptas consequatur aspernatur repellat perferendis sapiente qui dolor ipsam nihil omnis molestias minima consequatur.', 'Et commodi impedit expedita asperiores cum molestiae iste quis repudiandae vitae non voluptatum eos officiis cumque officiis quia magnam.', 1188328.463671882, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Dolor quidem totam illum quas voluptas est ea qui consequatur porro possimus distinctio.', 'Aut eaque nam veniam quo ducimus.', 4231343.874349884, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Iusto ut ipsam dignissimos quisquam cum sit accusantium voluptatem et voluptatem amet quasi amet dolor quia mollitia et rerum.', 'Beatae consequatur porro sed est illum fugiat molestias delectus non nobis qui sunt.', 3821068.642111992, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Amet rerum delectus est et reiciendis in tenetur in repudiandae vel pariatur.', 'Aut labore culpa et similique at et et fugit tempore ut nulla.', 4289667.14781228, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Sed sed explicabo consequatur nesciunt impedit.', 'Quo eveniet nesciunt qui aspernatur voluptate voluptas et vero consequatur voluptatibus voluptatem vero ut aut aut cupiditate pariatur in voluptas.', 1288636.4088806492, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Aut et sint quis quo eos.', 'Dignissimos eligendi omnis quia non soluta voluptas sed possimus eius et enim vel saepe eos et velit qui.', 1055907.8920892944, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Sint possimus et repudiandae quas fugiat minima quia dolor sed molestiae earum eaque natus.', 'Et id dignissimos nihil ipsa ea explicabo sit reiciendis.', 4042317.79605258, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Voluptatem odio porro ratione qui magni dolore.', 'Itaque repudiandae quia voluptatem nulla atque voluptates in aspernatur itaque quis omnis suscipit similique iste laudantium cumque deserunt est.', 1669066.854132836, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Necessitatibus sequi odit nam quaerat voluptas praesentium aut aut consequatur temporibus harum aliquid sit.', 'Quam in iste dolores sint vitae ipsa reprehenderit dolorum quo qui rerum aliquam.', 2794948.690475408, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Vitae molestias commodi voluptatem ab sint sit tempora qui fugit consequuntur fugiat.', 'Maiores cumque eius tempora recusandae minima sit magni tempore ut quos pariatur voluptas.', 2946652.610761416, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Aut quia cupiditate officiis consequatur impedit quia doloribus nemo deleniti et reprehenderit sit aliquid ea tenetur quia.', 'Harum dolores ut expedita quia dolorem numquam enim voluptate id accusamus quia quis et aliquid quam quaerat voluptates.', 3418828.834974592, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Minima culpa tempora sint qui omnis fuga et.', 'Et ut rerum itaque at optio sunt modi rerum ex.', 3642641.230785588, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Sint quia magni adipisci quasi eaque voluptates sunt quos.', 'Magnam quidem ex omnis consequatur quod accusamus reprehenderit officia molestias.', 1345983.8369609712, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Sed aliquid in expedita nulla aperiam accusantium magnam ullam dolores.', 'Veritatis odit repellendus quaerat impedit qui saepe incidunt aut adipisci reprehenderit ullam et qui similique atque perferendis delectus architecto omnis.', 1853565.203423408, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Mollitia voluptas dolores eum veritatis illo totam aspernatur hic et autem quos eveniet tenetur est soluta alias.', 'Vero explicabo dolores ratione ab architecto sint minima omnis aut veniam tempora qui voluptas.', 3607416.5471864, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Esse non sed eum quia perspiciatis explicabo odio.', 'Consequuntur et libero provident ea veniam quasi recusandae ea ipsam expedita ducimus autem quam et repellendus quas.', 2818538.934839208, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Repudiandae est quo qui voluptas adipisci rem et repellendus soluta omnis eaque impedit dolore hic et.', 'Voluptatem est alias nesciunt est voluptate suscipit expedita quod dolorum autem suscipit quae tempore.', 1352660.2947864032, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Rerum sint vel vitae voluptas non vel ut voluptatem cum voluptas et quod unde totam alias.', 'Atque nulla vel similique voluptatem sed quas.', 4721422.556658008, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Cum laudantium quod consequatur laudantium possimus asperiores ea et illo non aliquam qui consectetur.', 'Et qui sunt eaque repellat architecto quia suscipit accusamus consectetur et totam ratione dolorum ipsam nemo voluptatem quod rerum.', 1542413.02075908, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Tempore ullam vero placeat amet aperiam hic facilis tempora qui fuga.', 'Voluptas rem non saepe accusantium dolores aliquid magni accusamus illum modi nostrum nulla id sed.', 3977684.285015652, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Possimus illo dicta sunt inventore ad dolor dolore necessitatibus nostrum iure tempora sapiente.', 'Nulla totam vero nulla vel quaerat quo qui repellendus tempore ut at architecto similique ut ducimus sint.', 1814059.531695236, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Eligendi similique mollitia cum esse expedita porro dolor est veritatis maxime facilis at et dignissimos vel.', 'Ad consequatur sed et laborum enim velit omnis sed velit est nisi odio quis sit a magnam aspernatur ad.', 4486501.013620992, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quisquam perspiciatis non sed quisquam non eveniet alias facilis consequuntur cupiditate.', 'Facilis quo voluptatem voluptates beatae ullam sit quia non praesentium odit iusto dolorem eligendi.', 3245448.804574764, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Sit dolorem molestias optio nulla facilis sunt accusamus architecto unde atque expedita sed omnis.', 'Qui accusamus qui ut aut nisi sit reiciendis est inventore numquam quaerat.', 2748346.025938328, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Doloremque consequatur non in enim a perferendis accusamus et consectetur.', 'Eaque alias placeat optio totam aut et fuga et ullam sapiente numquam aut quaerat.', 2252908.716561696, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Rerum et iure eos autem nihil occaecati sed dignissimos et et non aut repellat non sequi incidunt nemo.', 'Tempora asperiores officia sed aliquid.', 4256400.346409716, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Et voluptatem sit eos repellat assumenda.', 'Incidunt ipsum aut odio distinctio ullam incidunt in.', 1097896.5945997724, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Aspernatur vel ullam aperiam veritatis est tenetur exercitationem sapiente dolorem illo nihil aperiam quia et.', 'Blanditiis ut fugit distinctio dolore possimus est assumenda possimus aliquid temporibus facilis quisquam repellat esse.', 3253010.858899452, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Porro et omnis doloremque sunt soluta amet cumque aut quis quia placeat assumenda sed nesciunt nam.', 'Est voluptates unde quam laboriosam sed non minima impedit eos nemo in sapiente voluptate quos molestiae ut.', 3422666.23974902, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Nihil debitis iusto voluptatum perspiciatis tenetur labore mollitia aut culpa tempore corrupti illo modi consequatur et ducimus enim.', 'Eos dolore facere vel qui debitis quia voluptas delectus nobis voluptatem.', 2699251.890973772, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Aut aliquid minus rem architecto officiis eum delectus recusandae ut magni amet qui cupiditate quod mollitia.', 'Voluptatibus architecto tempora sunt est tempore dolores et mollitia quam fugit enim voluptates est sequi neque voluptas dolore.', 4491116.689281128, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quis qui asperiores eveniet ipsam atque magnam.', 'Inventore animi aut consequatur pariatur suscipit ut veniam voluptatem velit soluta ut vero voluptatum qui.', 2082693.793383748, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('In aut accusantium inventore ad.', 'Occaecati expedita est soluta incidunt cum exercitationem amet et voluptatibus sed qui aut et inventore ex aut debitis.', 3458878.55368614, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Voluptas quia saepe earum est quia nostrum et.', 'Est alias quia ut nulla adipisci est libero illo.', 2895631.332833148, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Doloribus debitis itaque harum quaerat temporibus delectus modi dolorem ratione dignissimos modi.', 'Soluta suscipit porro quod quas totam alias veniam delectus quis sed dolores omnis inventore et.', 3513063.895755012, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Qui ratione cumque pariatur dignissimos tenetur enim totam quam voluptas soluta fugit laudantium natus aspernatur natus dolorem vero.', 'Non unde consequatur ut non.', 1108888.2908732112, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Dolores deleniti qui aspernatur mollitia accusantium quia corporis architecto aut eum.', 'Omnis molestiae eaque ab cum animi pariatur voluptates reiciendis qui eius necessitatibus consequatur et non ad dolores dolore corrupti.', 4292080.610660872, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quia maiores est tempora dicta dicta eos quaerat accusantium officia laboriosam ut magnam.', 'Molestias tenetur tempora laborum quia mollitia nihil quod voluptatem voluptas explicabo reiciendis.', 4267144.215883288, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Eum atque consequatur tenetur quia aliquam illo.', 'Ducimus excepturi voluptas assumenda quisquam quis et unde eaque consequatur.', 3843369.727415672, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Voluptatem debitis est nisi magni iusto quisquam.', 'Dolores odit enim sunt sunt adipisci aut suscipit sit ipsa et blanditiis officia omnis aspernatur velit dolorem cumque.', 2468565.9750684, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Illo laborum odit veniam voluptatibus aut id ea est.', 'Illum suscipit occaecati enim ea dolores.', 3726291.063579864, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Non numquam voluptatem quia totam enim deserunt.', 'Dolor ut sint molestiae quasi dicta omnis vitae.', 2987998.842256144, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Aut reprehenderit et aut voluptate delectus nihil sed quasi totam eligendi sint qui architecto consectetur odit beatae.', 'Quis rerum aut reprehenderit natus.', 4294903.734370556, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Et placeat magnam delectus incidunt voluptates.', 'Debitis occaecati repellendus doloremque labore et ea ipsa consectetur cupiditate.', 4107366.43667676, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quis aliquid debitis reiciendis rem ab non cupiditate eum quisquam.', 'Tempore pariatur enim enim tempore et aut labore repellendus officia ut omnis voluptate beatae voluptas quam non animi.', 4130620.674756644, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Id aut quisquam ullam officiis ad dolores dolor cumque aut ab et tenetur ex iure corporis quae.', 'Quia quam ut corporis qui odit et totam eveniet harum.', 3523603.108955364, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quae at quae itaque ipsa deserunt perferendis et deserunt est inventore dicta dolor eius placeat blanditiis est qui fugit.', 'Incidunt blanditiis ducimus dolore et architecto et et ea autem eos unde quam aut alias hic et esse nisi.', 3850572.673068648, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Minus vel deleniti eius hic necessitatibus ab perferendis quia sit sint qui eligendi officia.', 'Et molestias delectus aut sint qui numquam maxime molestias nam eveniet.', 1863117.380469628, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Enim odit ea pariatur nam est quidem voluptas numquam consequuntur qui ducimus reprehenderit.', 'Soluta aperiam voluptatem amet velit perspiciatis aut et.', 2505250.348479136, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Ipsum sint et ut omnis illo tempore magnam laudantium et architecto fugit unde.', 'Eos assumenda eaque exercitationem voluptas.', 1980408.661524024, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Perferendis veritatis voluptatum rerum impedit.', 'Quaerat ducimus ea minus nam sit quos non similique autem distinctio quasi inventore velit non laboriosam est.', 4676691.708935748, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Unde est et laborum provident quos qui.', 'Quas alias dolores voluptates nisi accusamus asperiores.', 1056762.455057708, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Qui eius sed et sed et harum assumenda amet et.', 'Tempore blanditiis iste dolorem omnis magnam.', 2931893.295576748, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Velit ipsum debitis quia impedit error ullam placeat qui amet quia sint debitis voluptatem totam quaerat fuga.', 'Sunt qui reiciendis omnis nemo qui aspernatur eum unde earum maxime autem et molestias harum tempore ratione veniam laboriosam.', 1840152.820963484, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Rerum rerum ipsa alias distinctio sequi quibusdam consectetur dicta et molestiae ex voluptates natus vel.', 'Et nostrum tempora debitis sit ex consequatur itaque sunt optio veniam.', 1830307.845412896, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Sint esse hic recusandae debitis explicabo quisquam.', 'Molestiae earum aperiam ex at quo et voluptatem mollitia.', 1279537.7002468044, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Esse ab voluptatibus et dolorum officia debitis aut et sapiente officiis officia quasi ut maiores molestias.', 'Reiciendis nobis porro quo natus commodi quis nulla nam quas dolorem.', 1288514.0424075136, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Numquam ut voluptate assumenda et et.', 'Ipsam quis numquam dolorum officiis sapiente quasi dignissimos veniam tenetur at ex vero dolorum eum eos repellat vero est.', 3789884.34317982, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Dicta quo doloremque quia et expedita labore distinctio magni sed beatae occaecati nam in quas explicabo nobis ea numquam in.', 'Omnis ipsam porro qui deleniti eum non velit repudiandae dolor minus.', 3650622.119498728, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quas officia facere aspernatur velit quia dolorum qui.', 'Minima suscipit a maiores quidem et quia quis deleniti qui in provident in ipsam libero eum.', 4307615.361785336, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Eius itaque nisi vero nemo adipisci repellat quas non.', 'Aut adipisci possimus qui culpa iusto fugit occaecati nulla.', 3286304.068884952, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Saepe aliquam voluptas dolor tempore odit ad dicta quo qui quia quis id autem itaque voluptatum.', 'Temporibus rerum ea et voluptatibus cum fuga illum et illum debitis omnis et voluptatibus praesentium.', 3976258.944243312, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Dicta perferendis cupiditate cupiditate saepe.', 'Nulla officia eius sit iure consequuntur temporibus et.', 3557099.740280352, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Recusandae aut dolores repudiandae in.', 'Sapiente accusamus nostrum qui provident pariatur animi porro.', 3504668.818090424, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Pariatur praesentium consequuntur ut maxime quia in reprehenderit blanditiis id et tempore accusantium vel repudiandae asperiores.', 'Cupiditate rerum maiores magni excepturi quibusdam error expedita id fugiat ipsam quod et corporis omnis alias ipsa est dolor.', 3967627.80983356, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Non aspernatur occaecati quia et provident adipisci.', 'Perferendis et at tempore consectetur maiores eos et laboriosam.', 3663030.890125328, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Qui nisi vitae est quo corporis libero libero maiores qui id aliquam qui laboriosam.', 'Rerum est iure sit aperiam praesentium laboriosam illum optio necessitatibus rerum aut omnis et molestiae enim.', 3047121.767907928, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Quae qui perferendis accusamus veniam enim eos.', 'Minima veniam aut animi non at ad magnam consequatur hic atque non voluptatem.', 4215901.042900936, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Omnis saepe adipisci saepe aut iste quam modi architecto ut exercitationem.', 'Officiis id odit accusamus ipsum recusandae.', 1236483.1847308592, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Nostrum quam aliquam et laborum quam ea accusantium et voluptatem labore inventore fuga aut reprehenderit sed ut quisquam.', 'Et expedita cupiditate natus natus voluptatem vel ut nulla et ea eius maxime repellat in rem.', 2897258.191321632, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Adipisci eos inventore velit nihil rerum illo et magnam et porro.', 'Velit non laboriosam nam sequi voluptas eos eligendi aliquid ut sequi sint velit nostrum aut dolores.', 1245184.5315495432, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Sint dolor culpa non qui aut praesentium aut laborum molestias vitae magni quidem consequuntur accusamus.', 'Consequatur voluptate sit quam impedit et dolore.', 1162781.6782159644, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Ut temporibus magni qui iste consequatur velit doloribus et similique et nobis facere vero eligendi nam dolore amet ut odit.', 'Iure perspiciatis dolores quibusdam dicta qui et non ullam recusandae ut similique animi.', 2062681.88406838, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Rem hic beatae non est voluptas ullam ut quia et rem est quae consequatur inventore est at totam voluptatem et.', 'Nisi rem ad sunt veritatis et harum beatae fugit sequi deserunt voluptatem eligendi omnis labore amet quia accusamus veritatis et.', 3367109.85487658, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Aliquam ut rerum recusandae debitis voluptas porro magni fugit molestiae aut.', 'Deleniti et ex qui eum nam laudantium.', 1823939.614381612, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Nihil aliquid deserunt qui qui cum animi sunt alias ea accusamus aperiam sit libero quia similique possimus enim in.', 'Deleniti deserunt porro est possimus.', 2545640.772928316, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Incidunt culpa magni enim recusandae autem adipisci provident laboriosam.', 'Dolor eaque non voluptatem molestiae.', 3278820.716905792, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Repellendus nobis voluptate voluptatem voluptates voluptatem aut voluptatum in fugit quidem rerum.', 'Velit vero voluptatem eos nihil.', 2105432.05081738, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Facilis voluptatum facilis tempora cumque magni.', 'Dolores praesentium dolorem ratione reprehenderit ipsam id dolores officiis ut.', 3683806.256709532, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Praesentium aut vitae saepe qui asperiores voluptatibus sit non neque consequatur exercitationem.', 'Laboriosam eos non voluptas eaque quia sit dignissimos reiciendis earum hic quos omnis maxime mollitia.', 3892166.880374852, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Facere ullam dolores facilis libero reprehenderit placeat eum impedit voluptatem sit quis exercitationem nesciunt at id aut laudantium et.', 'Recusandae laudantium a voluptatem deleniti aperiam.', 1532127.360129788, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Dolore iure praesentium voluptas enim aliquam asperiores occaecati optio rem qui perferendis quia et accusamus voluptatem eligendi facilis.', 'Quidem illum est magni et sit a quis laboriosam fugit neque quidem quaerat nisi maiores praesentium voluptas.', 3890087.468032764, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Et vero numquam ad doloribus.', 'Aspernatur est delectus sunt omnis temporibus.', 2542409.275445348, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Accusantium voluptatum aliquam expedita iusto ipsam delectus expedita ea sed quo natus libero modi eaque aut ut.', 'Dolorum aut omnis animi dolores qui optio.', 1929841.697649024, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Dolore ex autem magnam repudiandae in a maiores excepturi et.', 'Quo earum sed consequatur quod sequi.', 3170675.584194564, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Molestiae maiores eius et voluptas praesentium doloribus molestiae reiciendis aut a sed vitae.', 'Velit ab neque qui facilis sunt voluptatem illo deserunt voluptatum dicta voluptates earum in autem.', 4017023.626257212, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Et est qui quaerat dolores possimus atque.', 'Officia provident consequatur in odit aut et exercitationem temporibus omnis culpa similique.', 4592266.686070836, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Officiis qui maxime non at occaecati velit harum.', 'Consequuntur aut in ex magnam voluptatem repudiandae ea.', 1402313.18976838, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Minus ab adipisci consequatur quia minima facilis repellendus aperiam quia quam quaerat laudantium.', 'Occaecati et reprehenderit tempora et recusandae quia eveniet dolor ad corporis deleniti.', 2101948.090410768, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Nulla dolor totam impedit quo molestias dolorem velit autem quia in officiis fuga animi ab.', 'Perspiciatis itaque accusamus qui quis occaecati quia rem quaerat voluptas fugiat ut et et est alias.', 3394961.529595296, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Asperiores hic omnis fuga reiciendis optio nam.', 'Et illo inventore omnis ullam.', 3912489.495665064, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Ut voluptate voluptatem aliquid voluptas alias repellat qui molestias tempore iste minima enim mollitia sunt ad voluptatum.', 'Illo facere asperiores enim necessitatibus doloremque fuga molestias ut esse velit.', 4108202.512892056, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Aliquid enim amet mollitia minima quibusdam vero asperiores tenetur aspernatur sed corporis eos.', 'Nihil nemo deleniti dolor architecto aut tempore vel omnis incidunt sint.', 2145330.694106096, 'Nike');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Id culpa magnam minus eos sit non alias velit reiciendis asperiores soluta iste veritatis et saepe adipisci officia.', 'Et aut sapiente recusandae esse nihil et accusamus ut unde tenetur beatae asperiores architecto ipsa quaerat quis pariatur iure.', 1665389.625665448, 'Puma');

INSERT INTO `Products` (`Name`, `Description`, `Price`, `Brand`)
VALUES ('Cumque eveniet quas repellendus qui voluptas est perferendis et aperiam non qui.', 'Perferendis est facilis quo accusantium atque ratione reprehenderit qui blanditiis eveniet alias.', 3427452.123922972, 'Nike');

INSERT INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`)
VALUES ('20250123132642_fake product detail data', '8.0.11');

COMMIT;

START TRANSACTION;

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (80, 'superstar.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (12, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (45, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (78, 'jordan.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (13, 'superstar.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (64, 'jordan1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (37, 'jordan1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (55, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (90, 'jordan.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (62, 'superstar.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (10, 'superstar.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (73, 'jordan.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (40, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (95, 'jordan.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (30, 'superstar.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (62, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (78, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (80, 'superstar.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (81, 'jordan1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (53, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (70, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (71, 'jordan1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (26, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (22, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (85, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (56, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (44, 'jordan.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (52, 'jordan1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (71, 'jordan.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (48, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (79, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (84, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (82, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (54, 'superstar.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (49, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (85, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (65, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (88, 'jordan.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (77, 'superstar.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (80, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (55, 'jordan.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (25, 'superstar.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (89, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (42, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (36, 'superstar.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (87, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (78, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (82, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (13, 'jordan.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (43, 'jordan1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (25, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (46, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (89, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (17, 'superstar.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (18, 'jordan1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (57, 'jordan.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (28, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (27, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (55, 'jordan1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (72, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (49, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (25, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (12, 'jordan.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (90, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (20, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (12, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (18, 'superstar.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (47, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (67, 'jordan1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (59, 'jordan.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (75, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (66, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (91, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (58, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (58, 'jordan.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (48, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (40, 'superstar.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (89, 'superstar.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (48, 'superstar.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (86, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (91, 'jordan1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (33, 'jordan.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (37, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (14, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (40, 'jordan1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (12, 'jordan1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (80, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (26, 'superstar.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (17, 'jordan1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (13, 'jordan1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (54, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (35, 'jordan.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (51, 'jordan1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (36, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (56, 'r5io0spr.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (47, 'jordan1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (43, 'superstar1.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (20, 'superstar.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (68, 'superstar.jpg');

INSERT INTO `ProductImage` (`ProductId`, `FileName`)
VALUES (62, 'jordan.jpg');

INSERT INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`)
VALUES ('20250123134423_last fake data', '8.0.11');

INSERT INTO `Roles`(`Id`,`Name`) VALUES 
('UserId','User'),
('AdminId','Admin');

update roles
set NormalizedName = "ADMIN"
where Id = "AdminId";

update roles
set NormalizedName = "USER"
where Id = "UserId";

INSERT INTO users 
(Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed, PasswordHash, SecurityStamp, ConcurrencyStamp, PhoneNumberConfirmed, TwoFactorEnabled, LockoutEnabled, AccessFailedCount, Discriminator, TotalPurchase) 
VALUES 
('admin', 'admin', 'ADMIN', 'admin@gmail.com', 'ADMIN@GMAIL.COM', 1, 
'AQAAAAIAAYagAAAAEHO+IV2ynP5Z+08GhlBWack5DbY6l8Ym62XfpBXIlcp4ZrQLy8Ek7qnrl1C3LlSpNw==',
'RandomSecurityStamp', UUID(), 0, 0, 1, 0, 'User',0.0);

INSERT INTO users 
(Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed, PasswordHash, SecurityStamp, ConcurrencyStamp, PhoneNumberConfirmed, TwoFactorEnabled, LockoutEnabled, AccessFailedCount, Discriminator, TotalPurchase) 
VALUES 
('user', 'user', 'USER', 'user@gmail.com', 'USER@GMAIL.COM', 1, 
'AQAAAAIAAYagAAAAEOccNF9Y6rqlmVMMOKaLLsIucpvnNuHnppWTSMtyuYW03L6X0Y5Wi38JBnDAuxW5hw==',
'RandomSecurityStamp', UUID(), 0, 0, 1, 0, 'User', 0.0);

insert into userroles (UserId, RoleId)
values
('admin', 'AdminId'),
('user', 'UserId');

COMMIT;


